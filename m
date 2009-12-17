From: Dan Williams <dcbw@redhat.com>
Subject: Re: Linux driver for Broadcom BCM4312 [14e4:4315]
Date: Thu, 17 Dec 2009 14:12:25 -0800
Message-ID: <1261087945.1858.1.camel@localhost.localdomain>
References: <4B2A9199.2020006@postmail.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Divertito <marco.divertito@postmail.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760090AbZLQWMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 17:12:34 -0500
In-Reply-To: <4B2A9199.2020006@postmail.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-17 at 21:16 +0100, Marco Divertito wrote:
> Hi
> 
> I found some valuable help on
>     http://linuxwireless.org/en/users/Drivers/b43
> Thank you all.
> 
> I don't know if that has reached you already, but for the formentioned 
> PCI-WLAN-Controller
> there is a driver readily available at Broadcom's
>     http://www.broadcom.com/support/802.11/linux_sta.php

Yes, but that driver is a proprietary blob that nobody can fix or update
when new features hit the kernel.  The upstream 'b43' and 'b43-legacy'
drivers are the right place for any Broadcom wifi hardware support.

If you're interested in helping, I know the b43 project needs some help
implementing parts of the N-PHY spec still, and also help
reverse-engineering the LP-PHY bits that are common in netbooks.

Dan


