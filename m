From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC 1/2] netfilter: xt_condition: export list management code
Date: Mon, 19 Jul 2010 22:31:21 +0300
Message-ID: <1279567881.11662.104.camel@powerslave>
References: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
	 <1279548947-10470-2-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1007191807020.19191@obet.zrqbmnf.qr>
	 <1279566876.11662.102.camel@powerslave>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279566876.11662.102.camel@powerslave>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-07-19 at 21:14 +0200, Coelho Luciano (Nokia-MS/Helsinki)
wrote:
> On Mon, 2010-07-19 at 18:13 +0200, ext Jan Engelhardt wrote:
> > On Monday 2010-07-19 16:15, Luciano Coelho wrote:
> > >@@ -3,12 +3,27 @@
> > > 
> > > #include <linux/types.h>
> > > 
> > >+#define XT_CONDITION_MAX_NAME_SIZE 30
> > >+
> > > struct xt_condition_mtinfo {
> > >-	char name[31];
> > >+	char name[XT_CONDITION_MAX_NAME_SIZE + 1];
> > > 	__u8 invert;
> > 
> > Oh noes. Please please avoid any math operations inside []. It has 
> > already driven XT_FUNCTION_MAXNAMELEN into nuts ("was it now +1 or -1, 
> > or even -2 that we needed to pass for various functions?"). Just let MAX 
> > be 31 and have name[MAX].
> 
> Yeah, I had already done as you suggested in my previous module
> (IDLETIMER), I don't know what I had in my head today when I did it
> differently.  Even the name of the macro is totally wrong (_SIZE), it
> would make a tiny little bit more sense if it was _LEN.  I'll change it.

I was not very clear here, I meant I'll change to what you proposed, ie.
keep it _SIZE and use 31, of course.


-- 
Cheers,
Luca.

