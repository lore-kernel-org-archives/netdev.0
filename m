From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Thu, 25 Feb 2010 05:26:54 -0500
Message-ID: <4B86506E.40607@garzik.org>
References: <20100204075101.16661.95658.stgit@localhost.localdomain> <4B85F173.40703@garzik.org> <Pine.WNT.4.64.1002242258160.42728@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:36430 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758427Ab0BYK07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 05:26:59 -0500
Received: by gwj16 with SMTP id 16so1608848gwj.19
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 02:26:58 -0800 (PST)
In-Reply-To: <Pine.WNT.4.64.1002242258160.42728@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2010 02:04 AM, Waskiewicz Jr, Peter P wrote:
> On Wed, 24 Feb 2010, Jeff Garzik wrote:
>
>> On 02/04/2010 02:51 AM, Jeff Kirsher wrote:
>>> From: Peter Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>>>
>>> Program underlying ethernet devices with n-tuple flow classification
>>> filters.
>>>
>>> This also adds a new flag to ethtool_flags, allowing n-tuple
>>> programming to be toggled using the set_flags call.
>>>
>>> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
>>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>> ---
>>>
>>>    ethtool-copy.h |   35 +++++++++++++
>>>    ethtool.c      |  156 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
>>>    2 files changed, 186 insertions(+), 5 deletions(-)
>>
>> applied, but two problems remain:
>>
>> 1) you failed to document this in the man page.  I will expect a patch
>> to ethtool.8.
>
> And you shall have it shortly.  My bad.
>
>>
>> 2) you introduced a deviation from the upstream kernel ethtool.h:
>
> I see what happened.  We moved those two entries in ethtool.h into the
> #ifdef __KERNEL__ section.  I can create a patch for the kernel ethtool.h
> to move them back to match userspace if that is what folks want.

One way or another, userspace ethtool-copy.h must match the kernel's, 
and userspace ethtool does not build without those definitions...  They 
are de facto part of the interface at this point, though you are welcome 
to change that if you wish.

	Jeff



