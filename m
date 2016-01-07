From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 22/26] phylink: add EEE support
Date: Thu, 07 Jan 2016 12:34:25 -0800
Message-ID: <568ECBD1.30900@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zke-00076o-5v@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33949 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbcAGUfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:35:00 -0500
Received: by mail-pa0-f53.google.com with SMTP id uo6so248825353pac.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:34:59 -0800 (PST)
In-Reply-To: <E1a5zke-00076o-5v@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:39, Russell King wrote:
> Add EEE hooks to phylink to allow the phylib EEE functions for the
> connected phy to be safely accessed.

Looks good, a comment about why mac_link_up() now needs to have access
to phydev would be nice to have, just so it is clear, this is meant to
be used to call phy_init_eee() against.
-- 
Florian
