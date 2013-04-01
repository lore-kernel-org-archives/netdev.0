From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  net-sysfs: make flags symmetrical
Date: Mon, 01 Apr 2013 13:16:43 -0700
Message-ID: <5159EB2B.7070504@candelatech.com>
References: <20130401115315.1f8e4213@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51973 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205Ab3DAUQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 16:16:46 -0400
In-Reply-To: <20130401115315.1f8e4213@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2013 11:53 AM, Stephen Hemminger wrote:
> The flags reported by sysfs are the raw kernel flags, not the version
> exported to user space. This leads to the unsymmetrical behaviour that
> read != write. An example of this is when a device is part of a
> bridge.  The PROMISC flag returned from sysfs will not be the same as
> other API's.
>
> The reason this patch deserves wider discussion is someone might be
> depending on sysfs to read raw kernel flags.

I am depending on this feature.  There is no other way I know
of to determine if an interface is actually currently acting
PROMISC or not.

Please don't 'fix' this.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
