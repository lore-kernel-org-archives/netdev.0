From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sk98lin: 2 Pair Downshift detected
Date: Thu, 15 Feb 2007 13:35:32 -0800
Message-ID: <20070215133532.7523c7e3@freekitty>
References: <626DF2B4C31B7D4CA3820BD8245FC4AA0170EADA@AIEX01.ai.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Tony Chung" <tchung@appliedidentity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35101 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161413AbXBOVff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 16:35:35 -0500
In-Reply-To: <626DF2B4C31B7D4CA3820BD8245FC4AA0170EADA@AIEX01.ai.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Feb 2007 12:49:26 -0800
"Tony Chung" <tchung@appliedidentity.com> wrote:

> Hi,
> 
> I got the following message:
> 
>         Class:  Hardware failure
>         Nr:  0x270
>         Msg:  2 Pair Downshift detected
> 
> It is from the sk98lin driver and my research indicated that it may be
> caused by bad Ethernet cable.  The gigabit port is now became 100Mbps.
> 
> My questions are:
> 1. What is 0x270 mean? Is there any link or reference for it?

It is a error code used inside driver. It looks like a bad job of internationalization
so every message is encoded as a number, then printed out.


> 2. How do you recover from it (i.e. negotiate back to 1000Mbps)?
> Reboot? Reload the driver?  Can the driver do it automatically?

Use 'ethtool -r eth0' to force PHY renegotiation or bring device
down then back up.

> 
> Thanks.
> - Tony
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
