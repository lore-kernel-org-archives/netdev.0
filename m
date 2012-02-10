From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2 00/10] Low-level Ethernet debugging features.
Date: Thu, 09 Feb 2012 21:42:58 -0800
Message-ID: <4F34AE62.6070409@candelatech.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com> <4F349DB0.1010903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <tarbal@gmail.com>, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38345 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758959Ab2BJFnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 00:43:04 -0500
In-Reply-To: <4F349DB0.1010903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/2012 08:31 PM, Jeff Kirsher wrote:

> Thanks Ben!
>
> I have applied the series of 10 patches to my queue.  I would like to
> have our validation team validate the e100, e1000 and e1000e patches
> (and in-directly the net patches).

Just in case you can generate errored frames other than ones with just
bad FCS, I'm curious to know if rx-all logic works with them.

I was thinking I might could get at least some NICs to generate Runt frames
by sending small pkts and disabling frame padding, but haven't looked into
it too hard yet.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
