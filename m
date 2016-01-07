From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 04/26] phy: generate swphy registers on the fly
Date: Thu, 07 Jan 2016 11:49:47 -0800
Message-ID: <568EC15B.7090808@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zj9-00074l-TH@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32869 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729AbcAGTuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:50:21 -0500
Received: by mail-pa0-f41.google.com with SMTP id cy9so266272587pac.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:50:21 -0800 (PST)
In-Reply-To: <E1a5zj9-00074l-TH@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:37, Russell King wrote:
> Generate software phy registers as and when requested, rather than
> duplicating the state in fixed_phy.  This allows us to eliminate
> the duplicate storage of of the same data, which is only different
> in format.
> 
> As fixed_phy_update_regs() no longer updates register state, rename
> it to fixed_phy_update().
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
