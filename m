From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: Re: SO_REUSEADDR behavior different from BSD
Date: Thu, 05 Aug 2004 11:34:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040805.113437.91348248.yoshfuji@wide.ad.jp>
References: <20040805141444.GA2292@outpost.ds9a.nl>
	<19686.1091723777@www48.gmx.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mtk-lists@gmx.net
In-Reply-To: <19686.1091723777@www48.gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <19686.1091723777@www48.gmx.net> (at Thu, 5 Aug 2004 18:36:17 +0200 (MEST)), "Michael T Kerrisk" <mtk-lists@gmx.net> says:

> Now, on Linux, at this point, the second instance of the 
> server fails with EADDRINUSE, even though it did use 
> SO_REUSEADDR.  On FreeBSD 5.1, the second server instance 
> does successfully bind.

This behavior is intended.
First socket is REQUIRED to set SO_REUSEADDR
I hate BSD's behavior because it is asynmetry.
(Both sockets are required to agree on "REUSEADDR.")

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
