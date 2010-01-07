From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net/: use DEFINE_PCI_DEVICE_TABLE()
Date: Thu, 07 Jan 2010 17:28:00 -0500
Message-ID: <4B465FF0.80802@garzik.org>
References: <20100107215811.GA9357@x200> <1262903146.10429.83.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f188.google.com ([209.85.210.188]:59473 "EHLO
	mail-yx0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab0AGWeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 17:34:46 -0500
Received: by yxe26 with SMTP id 26so18158778yxe.4
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 14:34:45 -0800 (PST)
In-Reply-To: <1262903146.10429.83.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2010 05:25 PM, Joe Perches wrote:
> On Thu, 2010-01-07 at 23:58 +0200, Alexey Dobriyan wrote:
>> Use DEFINE_PCI_DEVICE_TABLE() so we get place PCI ids table into correct section
>> in every case.
>
> Good idea, but aren't there are some tables that are not const?

I hope not...  those tables are read by userland tools.

Messing with the PCI ID tables as runtime is highly unusual, to say the 
least.

	Jeff



