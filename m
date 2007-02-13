From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Tue, 13 Feb 2007 09:14:39 +0100
Message-ID: <20070213081439.GA21261@electric-eye.fr.zoreil.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com> <20061204000327.GE3625@electric-eye.fr.zoreil.com> <45D13578.8040405@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	isely@pobox.com
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37361 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177AbXBMIRy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 03:17:54 -0500
Content-Disposition: inline
In-Reply-To: <45D13578.8040405@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philip Craig <philipc@snapgear.com> :
[...]
> This patch caused a drop in throughput from 178 Mbits/sec to 135 Mbits/sec
> on an Intel XScale IXP465.

Which distribution of packet sizes ?

> It seems like there is some confusion about what the align parameter
> here means. It was originally an offset from an aligned address so that
> the IP header aligned, and this patch changes it to the alignment of the
> ethernet header. But align is still set to NET_IP_ALIGN for some chips.

Yes, I should have distinguished both in the first place.

Can you describe which chipset from realtek the board is using (lspci -vxx) ?

-- 
Ueimor
