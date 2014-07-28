From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: ethernet: intel: ixgbe: ixgbe_main.c:  Cleaning up
 missing null-terminate in conjunction with strncpy
Date: Mon, 28 Jul 2014 08:39:35 -0700
Message-ID: <20140728083935.6f4b77c1@samsung-9>
References: <1406384676-2606-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:65022 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbaG2CkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 22:40:16 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so11403086pad.41
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 19:40:15 -0700 (PDT)
In-Reply-To: <1406384676-2606-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Jul 2014 16:24:36 +0200
Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> wrote:

> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
			   hw->mac.type, hw->phy.type, hw->phy.sfp_type,

This patch doesn't change anything.
Netdev is already zeroed when allocated therefore doing strncpy() guarantees
it will be null terminated.
