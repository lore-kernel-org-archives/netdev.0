From: Shaun Pereira <spereira@tusc.com.au>
Subject: Re: [PATCH 5/6] x25: Allow 32 bit socket ioctl in 64 bit kernel
Date: Thu, 16 Feb 2006 16:40:26 +1100
Message-ID: <1140068426.4941.12.camel@spereira05.tusc.com.au>
References: <1140042162.8745.30.camel@spereira05.tusc.com.au>
	 <39e6f6c70602151435r5b965670oab580c75bbaee7ab@mail.gmail.com>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-kenel <linux-kernel@vger.kernel.org>,
	x25 maintainer <eis@baty.hanse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Andre Hendry <ahendry@tusc.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932480AbWBPFml@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
In-Reply-To: <39e6f6c70602151435r5b965670oab580c75bbaee7ab@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for that Aranaldo

I have corrected this so as to be compliant with OSI Network services
for DTE facilities and rebuilt and retested the patches
Corrected patches follow.



On Wed, 2006-02-15 at 20:35 -0200, Arnaldo Carvalho de Melo wrote:
> On 2/15/06, Shaun Pereira <spereira@tusc.com.au> wrote:
> 
> > +               switch (*p) {
> > +                       case X25_FAC_CALLING_AE:
> > +                               if (p[1] > 33)
> > +                               break;
> > +                               dte_facs->calling_len = p[2];
> > +                               memcpy(dte_facs->calling_ae, &p[3], p[1] - 1);
> > +                               *vc_fac_mask |= X25_MASK_CALLING_AE;
> > +                               break;
> 
> Can this '33' magic number be replaced with a define or sizeof(something)?
> 
> - Arnaldo
