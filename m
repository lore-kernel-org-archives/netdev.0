From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2] mac80211:  Optimize scans on current operating channel.
Date: Fri, 21 Jan 2011 10:06:17 -0800
Message-ID: <4D39CB19.5090505@candelatech.com>
References: <1295632988-7227-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41483 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab1AUSGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 13:06:18 -0500
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p0LI6H9q025526
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 21 Jan 2011 10:06:17 -0800
In-Reply-To: <1295632988-7227-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2011 10:03 AM, greearb@candelatech.com wrote:
> From: Ben Greear<greearb@candelatech.com>
>
> This should decrease un-necessary flushes, on/off channel work,
> and channel changes in cases where the only scanned channel is
> the current operating channel.

Sorry..meant to send this to linux-wireless....

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

