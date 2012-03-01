From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH v4 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Thu, 01 Mar 2012 14:40:17 +0100
Message-ID: <87zkc0783i.fsf@macbook.be.48ers.dk>
References: <1330490737-28973-1-git-send-email-mugunthanvnm@ti.com>
	<1330490737-28973-3-git-send-email-mugunthanvnm@ti.com>
	<87pqcxdbmp.fsf@macbook.be.48ers.dk>
	<EB1619762EAF8B4E97A227FB77B7E02931793847@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem\@davemloft.net" <davem@davemloft.net>
To: "N\, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:62823 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759340Ab2CAN7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 08:59:39 -0500
Received: by wibhm2 with SMTP id hm2so332280wib.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 05:59:38 -0800 (PST)
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E02931793847@DBDE01.ent.ti.com>
	(Mugunthan V. N.'s message of "Wed, 29 Feb 2012 16:28:48 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "N" == N, Mugunthan V <mugunthanvnm@ti.com> writes:

Hi,

 >> Is this really platform specific data (rather than SoC specific)? If
 >> it's purely a difference between 335x and 814x just use an id_table with
 >> different platform device names instead.

 N> Instead of driver maintaining the SoC specific offsets, SoC specific
 N> files in arch/arm/mach-omap2/ can hold this. Another reason is
 N> currently this IP is present in 2 SoCs, there are other SoC coming
 N> up where the offsets may change.

Sure, it's the same amount of code no matter where it gets put, but the
idea is to move code from arch/arm to drivers/ where possible. This will
also help if the IP is ever used on non-omap2 platforms and for device
tree support.

-- 
Bye, Peter Korsgaard
