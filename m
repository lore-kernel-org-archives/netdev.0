From: Steve.Glendinning@smsc.com
Subject: Re: SMSC LAN911x and LAN921x vendor driver
Date: Thu, 24 Aug 2006 12:09:42 +0100
Message-ID: <OFF68801AB.0EDE020C-ON802571D4.00388794-802571D4.003D513A@smsc.com>
References: <44ED2008.9000109@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Ian.Saturley@smsc.com, shemminger@osdl.org, netdev@vger.kernel.org,
	Bahadir Balban <Bahadir.Balban@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:5138 "EHLO smsc.com")
	by vger.kernel.org with ESMTP id S1751120AbWHXLKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 07:10:24 -0400
In-Reply-To: <44ED2008.9000109@garzik.org>
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

> What are the arguments for adding a duplicate driver, again?

The current driver is completely arm specific (does not even compile on 
!arm). While arm is certainly a  popular arch for us, we also have many 
customers on sh, x86 and others.  Currently there is no in-kernel support 
for these people.  Our smsc911x driver is tested and supported on arm, sh, 
i386.

smsc911x is a shorter, simpler driver, and I believe the coding style to 
be cleaner and easier to follow.

smsc911x contains support for the new LAN921x family, as well as LAN911x.

smsc911x contains important workarounds for currently known hardware 
issues.  Anyone using the current in-kernel driver with multicast will 
have problems.

Many of our customers use our proprietary drivers (GPL, but the coding 
style would make you scream), and we would like to migrate them over to a 
standard in-kernel driver - it would make support easier and everyone can 
benefit from ongoing driver improvements.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com
