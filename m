From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Driver for IBM System i/p VNIC protocol
Date: Mon, 07 Dec 2015 14:45:09 -0500 (EST)
Message-ID: <20151207.144509.1306012254991614677.davem@davemloft.net>
References: <1449251386-13476-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
	<20151205.222551.512793392902323297.davem@davemloft.net>
	<5665D4D8.7010206@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nguyendo@us.ibm.com,
	jallen@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	nfont@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519AbbLGTpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 14:45:12 -0500
In-Reply-To: <5665D4D8.7010206@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Mon, 7 Dec 2015 12:50:00 -0600

> Hi. Thanks for you feedback.  Could you clarify on what constitutes
> basic operation?  I just want to be sure if we should remove the
> other module parameters or just this one in particular?

With very minute exceptions, there should be no driver modules.

If a facility does not exist for run time configuration via ethtool
or similar, extend those facilities to suit your needs.
