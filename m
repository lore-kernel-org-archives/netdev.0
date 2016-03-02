From: Tomas Hlavacek <tmshlvck@gmail.com>
Subject: Re: RFC: blueprint for proxy PHY module
Date: Wed, 02 Mar 2016 15:24:01 +0100
Message-ID: <1456928642.7384.0@smtp.gmail.com>
References: <1456406760.28260.6@smtp.gmail.com>
	<20160225153113.GB7681@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: netdev@vger.kernel.org, Pavol Kor?ek <ikorcek@fit.vutbr.cz>,
	Martin Strba?ka <martin.strbacka@nic.cz>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35560 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbcCBOYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 09:24:06 -0500
Received: by mail-wm0-f51.google.com with SMTP id l68so87817024wml.0
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 06:24:04 -0800 (PST)
In-Reply-To: <20160225153113.GB7681@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew!

On Thu, Feb 25, 2016 at 4:31 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>>  Question is how to connect the userspace? I think that corresponding
>>  file in /sys would do the job, but I am not sure whether it is the
>>  proper way of doing that. (?)
> 
> A historian might be able to help you. Going back to the days of
> 10MBps Ethernet, cards used to have a few different ports, AUI, BNC
> and TP. The kernel probably supports configuring which to use,
> probably via ethtool. Your use case is not that different, so you can
> probably reuse it.

Extending the ethtool ops in the driver (namely mvneta) seems to be 
possible and it seems that I could add more phy_dev pointers to the 
private data of the driver and switch among them quite easily. But it 
would be driver specific hack and I believe this problem is more 
general.

Perhaps I can pass some common PHY switch command from the driver to 
the prospective phy-proxy module. I'll come back to this question when 
I haveproof-of-concept code.

Btw. thanks for the pointer to the phylink patchset.

Tomas
