From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Regarding sumbiting a new NIC driver to kernel.
Date: Fri, 1 Jul 2011 13:33:48 +0200
Message-ID: <20110701113348.GA4618@electric-eye.fr.zoreil.com>
References: <6349D7A510622448B1BA0967850A843801163B91@nasanexd02d.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'davem@davemloft.net'" <'davem@davemloft.net'>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44850 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265Ab1GALrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 07:47:31 -0400
Content-Disposition: inline
In-Reply-To: <6349D7A510622448B1BA0967850A843801163B91@nasanexd02d.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(insert the usual "only speaking on behalf of myself" here)

Ren, Cloud <cjren@qca.qualcomm.com> :
[...]
> Would you have any advices to us ?  If this is possible, how do I submit the
> new driver and remove the old driver? Can you give me a doc how to submit
> the driver to kernel or any hints ?

Advices:
- publish early for review and comments. Code is reviewed here, on netdev.
- work with the current atl* in-kernel drivers maintainers.
- provide a big-bang free migration path.
- read netdev. http://vger.kernel.org/vger-lists.html lists some archive.
- don't expect the convenience on maintenance to materialize immediately.

(old farts may appreciate shorter lines - somewhere between 72 and 80
chars - too)

If you have not done so yet, please consider reading:
- Documentation/CodingStyle
- Documentation/SubmittingPatches

Documentation/SubmittingDrivers is imho irrelevant here.

> Btw, why do we need to develop the new driver?
> The most important reason is for convenience on maintenance 1. we need to
> make HW operations uniform on all supported OS, such as WinXP, Win7 and Linux.
> 2. As our company is continuous to release new NICs, there are more and more
> drivers to support those NICs. It's a pity to develop and maintain so many
> drivers. So we have developed the driver, "alx". We will use it to support
> as many NICs as possible, including NICs released in future.

Platform neutral does not necessarily bode good things... :o/ 

Don't be shy, show the code.

-- 
Ueimor
