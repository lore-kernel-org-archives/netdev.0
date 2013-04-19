From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: rtl8168e-vl dropping tftp ack
Date: Fri, 19 Apr 2013 08:14:25 +0200
Message-ID: <20130419061425.GA14843@electric-eye.fr.zoreil.com>
References: <516EB23B.3080504@canonical.com>
 <20130417213251.GA13790@electric-eye.fr.zoreil.com>
 <516FC218.3060002@canonical.com>
 <20130418215501.GB8944@electric-eye.fr.zoreil.com>
 <DFF62ECF5DF14C65A71A35581D58FFA9@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Stefan Bader'" <stefan.bader@canonical.com>,
	netdev@vger.kernel.org, "'nic_swsd'" <nic_swsd@realtek.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57250 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756512Ab3DSGOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 02:14:33 -0400
Content-Disposition: inline
In-Reply-To: <DFF62ECF5DF14C65A71A35581D58FFA9@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> I don't think the hw checksum is enabled, because there are many successful
> small packets before the failure.

Tentative rationale: the first missing packet (112 at 88.147981) is a 60
bytes one whose tail does not contain zeroes only. Previous 60 bytes
packets would exhibit no change of content if they were they generously
cut or paded with zeroes.

> However, I also want to know if any skb->len < 60 occurs so I think the
> checking should be included by the other case.

I don't get it: arp aside, the normal trace in the capture file exhibits no
sub-60 bytes packet. Could you reformulate ?

-- 
Ueimor
