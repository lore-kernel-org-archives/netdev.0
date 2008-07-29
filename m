From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] forcedeth bug fix: realtek phy 8211c errata
Date: Tue, 29 Jul 2008 14:56:32 -0700
Message-ID: <20080729145632.663435f1.akpm@linux-foundation.org>
References: <488A2A11.4080000@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, manfred@colorfullife.com,
	netdev@vger.kernel.org, stable@kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58205 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752332AbYG2V5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 17:57:20 -0400
In-Reply-To: <488A2A11.4080000@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jul 2008 15:31:29 -0400
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> This patch adds support for the realtek 8211c phy. The driver must 
> perform a hardware reset of the phy due to an errata where the phy could 
> not detect the link.

Would you consider this fix to be needed in 2.6.25.x?  2.6.26.x?

The patch applies OK to 2.6.26, but gets lots of rejects against 2.6.25.

