From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Bridge & it's MAC address question
Date: Mon, 30 Oct 2006 07:28:37 -0800
Message-ID: <20061030072837.51177183@localhost.localdomain>
References: <200610301527.15018.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@osdl.org, devel@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55188 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030532AbWJ3P2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 10:28:46 -0500
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200610301527.15018.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Oct 2006 15:27:14 +0300
Dmitry Mishin <dim@openvz.org> wrote:

> Hi,
> 
> Could somebody explain, why bridge uses minimal MAC of the attached devices?
> It makes this address instable, variable during bridge life-cycle, which is 
> not good for DHCP. For example, I want to attach multiple virtual devices to 
> one physical. Then, I need to make sure that after each virtual device 
> addition, bridge addr is not changed and still addr of the physical device.  
> Why not to use MAC of the first attached device?
> 

The bridge physical address is the minimum of all the attached devices.
This is done because the STP standard requires it.  You can reset it
to be the same as any of the attached devices. This will not cause a problem
unless using STP.
