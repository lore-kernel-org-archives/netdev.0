From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 04:40:37 +0100
Message-ID: <20130324034037.GC17948@order.stressinduktion.org>
References: <1363996448.4431.73.camel@edumazet-glaptop> <514CF23A.3010702@gmail.com> <20130323021008.GC939@order.stressinduktion.org> <514D3581.4040001@gmail.com> <20130323150655.GA10779@order.stressinduktion.org> <69jo698argv8@mids.svenhartge.de> <20130324012625.GA17948@order.stressinduktion.org> <89joa2largv8@mids.svenhartge.de> <20130324014125.GB17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54353 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab3CXDkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 23:40:39 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 03:27:55AM +0000, Huang, Xiong wrote:
> Could you point me where the patch is ? 
> I checked windows driver, it doesn't disable checksum offload in RX direction.


The patch is here: <http://article.gmane.org/gmane.linux.network/263116>

It does not disable checksum offloading but rather suppress the update of the
ip_summed field. This forces the kernel to recheck the checksums and discard
the packet. Otherwise it would be seen as a valid one and could corrupt data
streams.

Thanks,

  Hannes
