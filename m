From: Geoff Levand <geoff@infradead.org>
Subject: Re: [PATCH 0/3] ps3_gelic: Fix error paths when a tx dma fails
Date: Thu, 14 Jul 2011 10:10:07 -0700
Message-ID: <4E1F22EF.4010202@infradead.org>
References: <1310501606-829-1-git-send-email-a.heider@gmail.com>	<4E1E1CDE.2060504@infradead.org>	<CAHsu+b89+SN8RE4Ce-evC97pw8bgZgjnOW_+z6NDXu6bGuRO+w@mail.gmail.com> <20110714.083548.1565604077412861146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <a.heider@gmail.com>, <netdev@vger.kernel.org>,
	<cbe-oss-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe004.messaging.microsoft.com ([213.199.154.142]:54656
	"EHLO DB3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932113Ab1GNRK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 13:10:29 -0400
In-Reply-To: <20110714.083548.1565604077412861146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On 07/14/2011 08:35 AM, David Miller wrote:
> From: Andre Heider <a.heider@gmail.com>
> Date: Thu, 14 Jul 2011 10:36:32 +0200
>> 
>> On Thu, Jul 14, 2011 at 12:31 AM, Geoff Levand <geoff@infradead.org> wrote:
>>> Hi Andre,
>>>
>>> On 07/12/2011 01:13 PM, Andre Heider wrote:
>>>> This series fixes a few bugs for the error paths once a tx dma request
>>>> fails. Without these I either ran into BUG_ON, the device got killed,
>>>> or the kernel crashed.
>>>
>>> Thanks for preparing the fixes.  I added them to my ps3-linux
>>> tree and did some quick tests which didn't show any problems.
>>> I'll try to do some more through testing with them sometime
>>> soon.
> 
> Should I toss these into net-next-2.6 now?

It seems reasonable to add these in.  I also have a fix for an
RX interrupt hang that I'll send you.

Acked-by: Geoff Levand <geoff@infradead.org>

