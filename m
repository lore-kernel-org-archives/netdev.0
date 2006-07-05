From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Belkin F5D7001de locks up my Athlon64 system
Date: Wed, 05 Jul 2006 15:42:44 +0100
Message-ID: <44ABCFE4.4010808@gentoo.org>
References: <20060701092313.225240@gmx.net> <200607011828.37874.mb@bu3sch.de> <20060702113205.16230@gmx.net> <200607022028.39852.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johann Uhrmann <Johann.Uhrmann@gmx.de>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:29693 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S964891AbWGEOh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 10:37:56 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607022028.39852.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> The following patch is supposed to fix this.
> I did only compile-test it. Please runtime-test it.
> 
> Thanks.
> 
> --
> 
> Softmac Shared Key Auth:
> Fix recursive call into the driver by doing schedule_work.
> recursive calls may result in a driver lock recursion.

Tested on zd1211rw with shared key auth, works fine.

Daniel

