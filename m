From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Wed, 25 May 2016 13:04:38 -0600
Message-ID: <2b0cb64c-8ac8-938e-4b62-f9851fc6a8c1@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
 <loom.20160525T180336-546@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Chenna <chenna.reboot@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33757 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbcEYTEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 15:04:46 -0400
Received: by mail-io0-f195.google.com with SMTP id s67so6178381ios.0
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 12:04:46 -0700 (PDT)
In-Reply-To: <loom.20160525T180336-546@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/25/16 10:04 AM, Chenna wrote:
> David Ahern <dsahern <at> gmail.com> writes:
>
>>
>> Kernel patches are also available here:
>>     https://github.com/dsahern/linux.git vrf-3.19
>>
>> iproute2 patches are also available here:
>>     https://github.com/dsahern/iproute2 vrf-3.19
>>
>
>
> Hello David,
>
> Do we have the similar support package for 3.10 kernel?

The VRF patches referenced above were not accepted upstream. An 
alternative implementation was accepted for the 4.3 kernel with various 
updates in all of the kernel versions since.

Users that want the VRF implementation in an older kernel (e.g., 3.10) 
will need to backport the kernel patches. Top of tree iproute2 can be 
used as is with older kernels.
