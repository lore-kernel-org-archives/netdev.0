From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 12/26] phylink: add hooks for SFP support
Date: Thu, 07 Jan 2016 12:05:51 -0800
Message-ID: <568EC51F.1020809@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zjo-00075h-UD@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34033 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbcAGUG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:06:28 -0500
Received: by mail-pa0-f52.google.com with SMTP id uo6so248294708pac.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:06:28 -0800 (PST)
In-Reply-To: <E1a5zjo-00075h-UD@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> Add support to phylink for SFP, which needs to control and configure
> the ethernet MAC link state.  Specifically, SFP needs to:
> 
> 1. set the negotiation mode between SGMII and 1000base-X
> 2. attach and detach the module PHY
> 3. prevent the link coming up when errors are reported
> 
> In the absence of a PHY, we also need to set the ethtool port type
> according to the module plugged in.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
