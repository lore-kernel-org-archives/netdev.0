From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: help regarding ip address assignment in kernel module
Date: Mon, 04 Dec 2006 07:35:46 -0800
Message-ID: <45744052.1060008@osdl.org>
References: <e9010580612032106p30f561f7h999acaf2f5255aa3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:60158 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937027AbWLDPfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 10:35:50 -0500
To: prajakta choudhari <prajaktachoudhari@gmail.com>
In-Reply-To: <e9010580612032106p30f561f7h999acaf2f5255aa3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

prajakta choudhari wrote:
> Hi all:
> I am absolutely new to kernel module programming. I have to modify the
> hostap -code such that whenever a network device is registered, it is
> assigned an ip address.
Do it in userspace. Listen for the netlink event that occurs when network
device is registered and send a netlink message to assign an IP address.

