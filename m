From: Miika Komu <miika@iki.fi>
Subject: Re: [PATCH] [NET] Exporting of some IPv6 symbols for HIP and SHIM6
 experimentation
Date: Tue, 6 May 2008 11:07:49 +0300 (EEST)
Message-ID: <Pine.SOL.4.64.0805061052470.28110@kekkonen.cs.hut.fi>
References: <Pine.SOL.4.64.0804292344490.29274@kekkonen.cs.hut.fi>
 <20080429.152014.00555445.davem@davemloft.net> <Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi>
 <20080505.150045.29715304.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-559023410-1144747756-1210061269=:28110"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twilight.cs.hut.fi ([130.233.40.5]:50134 "EHLO
	twilight.cs.hut.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754657AbYEFIHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 04:07:51 -0400
In-Reply-To: <20080505.150045.29715304.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---559023410-1144747756-1210061269=:28110
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Mon, 5 May 2008, YOSHIFUJI Hideaki / µÈÆ£±ÑÌÀ wrote:

Hi,

> In article <Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi> (at Mon, 5 May 2008 08:55:49 +0300 (EEST)), Miika Komu <miika@iki.fi> says:
>
>> On Tue, 29 Apr 2008, David Miller wrote:
> :
>>> This is not how we do things.
>>>
>>> When the HIP implementation is submitted for inclusion, the module
>>> exports can be added, not before.
>>
>> I am sorry but this somewhat conflicts with your earlier statement:
>>
>> http://www.linux.sgi.com/archives/netdev/2005-03/msg01214.html
>>
>> We took an huge effort in our project to move the HIP implementation to
>> the userland. I feel puzzled on how to continue. Please give some advice?
>
> Miika, where are your other patches on top of this?
> This kind of change might be okay, but it must be along with
> its users, at least.

we are maintaining a separate kernel module (GPLv2) for the HIP socket 
handler for experimentation purposes. If you want to have a look it, you 
can e.g. download the nightly tarball and have a look at the hipsock 
directory:

http://infrahip.hiit.fi/hipl/hipl.tar.gz

The kernel module is currently out of synch with the latest draft, so I 
need to update it. The purpose of the kernel module is to be a "wrapper" 
for IPv6 socket calls because HIP can use ORCHID IPv6 addresses. We would 
like to experiment with various socket options for HIP and SHIM6. 
Exporting the symbols would make HIPL developers and users life easier. 
Once we have a clear set of requirements for the kernel module, we can 
contribute the changes to the vanilla kernel.

-- 
Miika Komu                                       http://www.iki.fi/miika/
---559023410-1144747756-1210061269=:28110--
