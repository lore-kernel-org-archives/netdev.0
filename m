From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Fri, 29 Mar 2013 04:05:45 +0100
Message-ID: <20130329030545.GE20223@order.stressinduktion.org>
References: <20130327223433.GE23223@order.stressinduktion.org> <157393863283F442885425D2C45428564F1FFFCE@nasanexd02f.na.qualcomm.com> <20130328004024.GA2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F200FE9@nasanexd02f.na.qualcomm.com> <20130328011602.GB2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F200FFD@nasanexd02f.na.qualcomm.com> <20130328031932.GC2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F201026@nasanexd02f.na.qualcomm.com> <20130328032934.GD2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F201039@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37685 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753829Ab3C2DFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 23:05:46 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C45428564F201039@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 03:39:33AM +0000, Huang, Xiong wrote:
> Dump every packet length & read_offset value,  compare them.

I think we have it! :)

If we disable msi as it is done in the windows driver, everything works as
expected. Do you have any clue why this could be the case? Otherwise I would
send a patch to disable msi by default.

Thanks for your help,

  Hannes
