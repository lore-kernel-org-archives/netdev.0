From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Thu, 8 Jan 2009 13:59:27 +0000
Message-ID: <20090108135927.GC5493@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <20090108094231.GD4496@ff.dom.local> <20090108095403.GE4496@ff.dom.local> <20090108100614.GA5418@ff.dom.local> <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt> <20090108110430.GB5493@ff.dom.local> <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: mysql.jorge@decimal.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:39493 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021AbZAHN7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 08:59:35 -0500
Received: by ewy12 with SMTP id 12so3132768ewy.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 05:59:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 11:22:01AM -0000, mysql.jorge@decimal.pt wrote:
...
> lira:~# ethtool -k eth0
> Offload parameters for eth0:
> Cannot get device flags: Operation not supported
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> udp fragmentation offload: off
> generic segmentation offload: off
> large receive offload: off
> 

Could you try to check this with scatter-gather and tcp segmentation
offload off too? If there is no difference please send the stats
again both for working and non-working case.

Thanks,
Jarek P.
