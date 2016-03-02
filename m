From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6/l3mdev: Move host route on saved
 address if necessary
Date: Tue, 1 Mar 2016 17:46:46 -0800
Message-ID: <56D64606.7040202@cumulusnetworks.com>
References: <1456595957-29477-1-git-send-email-dsa@cumulusnetworks.com>
 <20160301.172312.1539246311423803200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33920 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754841AbcCBBqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 20:46:49 -0500
Received: by mail-pf0-f169.google.com with SMTP id 4so45144128pfd.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 17:46:48 -0800 (PST)
In-Reply-To: <20160301.172312.1539246311423803200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/16 2:23 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sat, 27 Feb 2016 09:59:17 -0800
>
>> Commit f1705ec197e70 allows IPv6 addresses to be retained on a link down.
>> The address can have a cached host route which can point to the wrong
>> FIB table if the L3 enslavement is changed (e.g., route can point to local
>> table instead of VRF table if device is added to an L3 domain).
>>
>> On link up check the table of the cached host route against the FIB
>> table associated with the device and correct if needed.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> Ugly... but applied, thanks.
>

This is an example of what I meant by complications with the suggestion 
of stashing the prefix route. Would you prefer the host route always get 
freed on a down and re-created on an up?
