From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: 2.6.19: very low transmit speed after suspend/resume with Sky2
Date: Thu, 7 Dec 2006 11:32:19 +0100
Message-ID: <20061207103219.GA9864@dose.home.local>
References: <20061202091626.GA20734@thinkpad.home.local> <20061202131833.GA3673@thinkpad.home.local> <4571ED2C.6040005@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:37261 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032002AbWLGKcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 05:32:20 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <4571ED2C.6040005@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 02, 2006 at 13:16:28 -0800, Stephen Hemminger wrote:

[...]

> Most likely, the problem is similar to one I am working. The 
> device_resume code gets run before
> BIOS. And the BIOS wakeup screws up the device. The proper fix will 
> happen in 2.6.20.

Hum, are you talking about suspend to RAM here? I forgot to mention
that I use suspend to disk.

Regards,
Tino
