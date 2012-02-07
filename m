From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/2] e100: Support RXFCS feature flag.
Date: Tue, 07 Feb 2012 15:55:28 -0800
Message-ID: <4F31B9F0.5000407@candelatech.com>
References: <1328553547-27337-1-git-send-email-greearb@candelatech.com> <1328553547-27337-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51642 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754296Ab2BGXz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 18:55:29 -0500
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q17NtSHt018493
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 7 Feb 2012 15:55:28 -0800
In-Reply-To: <1328553547-27337-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2012 10:39 AM, greearb@candelatech.com wrote:
> From: Ben Greear<greearb@candelatech.com>
>
> This allows e100 to be configured to append the
> Ethernet FCS to the skb.
>
> Useful for sniffing networks.

This patch actually works in testing, but I think I might
be getting lucky somehow.  I think I need to add an ndo_set_features
method that resets the chip when the rxfcs flag is toggled...

So, please do not apply this version of this patch, I'll
re-send these when I complete that change and test it.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
