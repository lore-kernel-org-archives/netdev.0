From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: SO_REUSEADDR behavior different from BSD
Date: Sat, 07 Aug 2004 23:25:13 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4.3.2.7.2.20040807232436.00d6da60@pop.gmx.net>
References: <19686.1091723777@www48.gmx.net>
 <20040805141444.GA2292@outpost.ds9a.nl>
 <19686.1091723777@www48.gmx.net> <20040805.113437.91348248.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: ahu@ds9a.nl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>,
        mtk-lists@gmx.net
In-Reply-To: <20040805.113437.91348248.yoshfuji@wide.ad.jp>
References: <19686.1091723777@www48.gmx.net>
 <20040805141444.GA2292@outpost.ds9a.nl>
 <19686.1091723777@www48.gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 11:34 05/08/2004 -0700, YOSHIFUJI Hideaki wrote:

> > Now, on Linux, at this point, the second instance of the
> > server fails with EADDRINUSE, even though it did use
> > SO_REUSEADDR.  On FreeBSD 5.1, the second server instance
> > does successfully bind.
>
>This behavior is intended.
>First socket is REQUIRED to set SO_REUSEADDR
>I hate BSD's behavior because it is asynmetry.
>(Both sockets are required to agree on "REUSEADDR.")

Not sure what you mean by "asymetry".


--
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@acm.org
