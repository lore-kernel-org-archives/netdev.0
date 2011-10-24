From: David Miller <davem@davemloft.net>
Subject: Re: [RFD] Network configuration data in sysfs
Date: Sun, 23 Oct 2011 20:49:43 -0400 (EDT)
Message-ID: <20111023.204943.1509703901636083438.davem@davemloft.net>
References: <20111023233558.GA23264@shutemov.name>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, gregkh@suse.de,
	kay.sievers@vrfy.org, gladkov.alexey@gmail.com
To: kirill@shutemov.name
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab1JXAwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 20:52:46 -0400
In-Reply-To: <20111023233558.GA23264@shutemov.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Mon, 24 Oct 2011 02:35:58 +0300

> Is there something fundamental preventing us to have sysfs interface for
> network configuration?

Netlink already provides everything sysfs would potentially provide as
well as event tracking.

udev could just listen to a netlink socket and notice all changes to
addresses, routes, and device states.
