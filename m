From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC VLAN 01/10]: Fix off-by-ones in VLAN ID checks
Date: Tue, 05 Jun 2007 09:16:31 -0700
Message-ID: <46658C5F.8050302@candelatech.com>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain> <20070605143651.23717.20253.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:34146 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933297AbXFEQQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 12:16:33 -0400
In-Reply-To: <20070605143651.23717.20253.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> [VLAN]: Fix off-by-ones in VLAN ID checks
>
> The valid range of VLAN IDs is 0-4095, fix using ID 4095.
>   
Per http://standards.ieee.org/getieee802/download/802.1Q-1998.pdf
page 69

0xFFF is reserved for future use, so we should not be using VLANs with 
that VID.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


