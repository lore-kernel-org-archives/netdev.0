From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/4] forcedeth: fix power management support
Date: 29 May 2007 11:31:18 +0200
Message-ID: <p734plwf02h.fsf@bingen.suse.de>
References: <465237E8.1060005@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:38062 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbXE2Ien (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 04:34:43 -0400
In-Reply-To: <465237E8.1060005@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla <aabdulla@nvidia.com> writes:

> This patch fixes the power management functions. It includes lowering
> the phy speed to conserve power.

Shouldn't there be some way to disable this? AFAIK a few old switches
have trouble with this. I assume a new ethtool option would be appropiate
since we expect other drivers to gain this capability too.
Could some of this code be put into the generic MII layer?

-Andi

