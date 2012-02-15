From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [REGRESSION, PATCH] sky2 WOL fix
Date: Wed, 15 Feb 2012 09:16:22 -0800
Message-ID: <20120215091622.429fe9c3@nehalam.linuxnetplumber.net>
References: <4F3A1A5E.9090803@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dilieto@lineone.net,
	Mirko Lindner <mlindner@syskonnect.de>,
	Ralph Roesler <rroesler@syskonnect.de>
To: Knut Petersen <Knut_Petersen@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50812 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752905Ab2BORQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 12:16:26 -0500
In-Reply-To: <4F3A1A5E.9090803@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Feb 2012 09:25:02 +0100
Knut Petersen <Knut_Petersen@t-online.de> wrote:

> From f3a7086638b0ee1f9d9e9028a188d96646671088 Mon Sep 17 00:00:00 2001
> From: Knut Petersen <Knut_Petersen@t-online.de>
> Date: Tue, 14 Feb 2012 08:35:17 +0100
> Subject: [PATCH] Fix an old sky2 WOL regression
> 
> Wake-On-Lan was broken for a few systems with commit
> 87b09f1f25cd1e01d7c50bf423c7fe33027d7511 more than a
> year ago.
> 
> This commit fixes the regression for the AOpen i915GMm-HFS
> motherboard. It reintroduces the old code, but that code is
> only executed for those system included in a dmi_system_id
> list. Currently there is only one entry in that list, but
> it probably will grow.
> 
> Signed-off-by: Knut Petersen <Knut_Petersen@t-online.de>

You might also want to check with AOpen to see if there is a BIOS
update. Often the BIOS programs bits on the onboard card to deal
with power management issues.
