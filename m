From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: New build error - ndo_set_mac_addr
Date: Wed, 14 Jan 2009 19:47:46 +0000
Message-ID: <20090114194746.GL22976@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:33965 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbZANTrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 14:47:52 -0500
Received: from n2100.arm.linux.org.uk ([2002:4e20:1eda:1:214:fdff:fe10:4f86])
	by caramon.arm.linux.org.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <linux@arm.linux.org.uk>)
	id 1LNBiO-0006Dk-Gb
	for netdev@vger.kernel.org; Wed, 14 Jan 2009 19:47:48 +0000
Received: from linux by n2100.arm.linux.org.uk with local (Exim 4.69)
	(envelope-from <linux@n2100.arm.linux.org.uk>)
	id 1LNBiM-0000P3-VK
	for netdev@vger.kernel.org; Wed, 14 Jan 2009 19:47:46 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new build error poped up between rc1-git2 and rc1-git3.

drivers/net/arm/etherh.c:649: error: unknown field 'ndo_set_mac_addr' specified in initializer

Looks like this should've been ndo_set_mac_address ?
