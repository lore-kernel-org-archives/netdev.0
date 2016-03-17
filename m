From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] Add support to control PHY LEDs
Date: Thu, 17 Mar 2016 15:54:29 +0100
Message-ID: <20160317145429.GC26019@lunn.ch>
References: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ujhelyi.m@gmail.com, f.fainelli@gmail.com, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49377 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030201AbcCQOya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 10:54:30 -0400
Content-Disposition: inline
In-Reply-To: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 02:59:06PM +0100, Vishal Thanki wrote:
> Hi all,
> 
> We had a requirement to disable the PHY link LEDs during system
> standby mode without turning off the ethernet module. To achieve that,
> I have prepared the sysfs interface turn on/off the PHY link LEDs.

Hi Vishal

Could you implement this in at803x_suspend()?

      Andrew
