From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Fri, 20 Jul 2007 17:22:58 +0100
Message-ID: <OFE56EBEC8.1BEEC22C-ON8025731E.0057D9A8-8025731E.0059FE8A@smsc.com>
References: <469E9648.6050209@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir Balban <Bahadir.Balban@arm.com>,
	Bill Gatliff <bgat@billgatliff.com>,
	Dustin Mcintire <dustin@sensoria.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1643 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763227AbXGTQjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 12:39:08 -0400
In-Reply-To: <469E9648.6050209@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

> Where is the hard_start_xmit/TX-completion locking?

The entire PIO Tx operation is performed within hard_start_xmit, so should 
be covered by netif_tx_lock.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

