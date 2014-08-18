From: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Subject: Re: [PATCH] drivers: net: ethernet: intel: e1000: e1000_ethtool.c
 coding style fixes
Date: Mon, 18 Aug 2014 17:43:40 +0200
Message-ID: <53F21F2C.9010905@vipserv.org>
References: <1408180328-4827-1-git-send-email-cristos@vipserv.org>	 <1408214489.2683.87.camel@joe-AO725> <53F21BEC.2070204@intel.com>	 <1408375914.2741.1.camel@joe-AO725> <53F21D6F.7000306@vipserv.org> <1408376459.2741.4.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408376459.2741.4.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/08/14 17:40, Joe Perches wrote:
> On Mon, 2014-08-18 at 17:36 +0200, Krzysztof Majzerowicz-Jaszcz wrote:
>> On 18/08/14 17:31, Joe Perches wrote:
>>> On Mon, 2014-08-18 at 08:29 -0700, Alexander Duyck wrote:
>>>> Doing any kind of pointer math on a void pointer is generally unsafe as
>>>> it is an incomplete type.  The only reason why it works in GCC is
>>>> because GCC has a nonstandard extension that makes it report as having a
>>>> size of 1.
>>>
>>> I know.  It's used in quite a few places in kernel code
>>> so I believe it's now a base assumption for the kernel.
>>>
>> Ok, so what do you suggest - void* or char* here ?
> 
> Do what you (or Alex) think is best.
> 
> My main point was trying to make the code a bit
> clearer.a
> 
OK, thank you for your suggestions. I'll send an updated version of this patch soon.
