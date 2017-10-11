From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] rtl8xxxu: mark expected switch fall-throughs
Date: Wed, 11 Oct 2017 10:47:13 -0700
Message-ID: <1507744033.3552.55.camel@perches.com>
References: <20171010193027.GA23108@embeddedor.com>
         <1507717237.3552.48.camel@perches.com>
         <063D6719AE5E284EB5DD2968C1650D6DD009123C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Arnaldo Carvalho de Melo <acme@infradead.org>
To: David Laight <David.Laight@ACULAB.COM>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Jes Sorensen <Jes.Sorensen@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD009123C@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-11 at 12:54 +0000, David Laight wrote:
> From: Joe Perches
> > Sent: 11 October 2017 11:21
> > On Tue, 2017-10-10 at 14:30 -0500, Gustavo A. R. Silva wrote:
> > > In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> > > where we are expecting to fall through.
> > 
> > perhaps use Arnaldo's idea:
> > 
> > https://lkml.org/lkml/2017/2/9/845
> > https://lkml.org/lkml/2017/2/10/485
> 
> gah, that is even uglier and requires a chase through
> headers to find out what it means.

Sure, if you think __fallthrough; isn't self-documenting.

	case foo;
		bar;
		__fallthrough;
	case baz;
		etc...



		
