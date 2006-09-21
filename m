From: mabbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 2/7] d80211: add support for SIOCSIWRATE and SIOCGIWRATE
Date: Thu, 21 Sep 2006 09:59:39 -0700
Message-ID: <4512C4FB.5010704@linux.intel.com>
References: <44F355EE.3090607@linux.intel.com>	<20060830171919.GC18041@instant802.com> <20060921184021.1fb7fa6e@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:46206 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751347AbWIURAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 13:00:45 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060921184021.1fb7fa6e@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> On Wed, 30 Aug 2006 10:19:19 -0700, Jouni Malinen wrote:
>   
>> On Mon, Aug 28, 2006 at 01:45:34PM -0700, mabbas wrote:
>>
>>     
>>> This patch modify d80211 to add SIOCSIWRATE and SIOCGIWRATE
>>> commands. this patch almost does the same thing as in 
>>> PRISM2_HOSTAPD_SET_RATE_SETS.
>>>       
>> I don't think I would like to get this applied since this seems to be
>> changing the design on how the per-STA TX rate limiting is done in a
>> way that does not match the original design and no justification has
>> been given for that change so far. Some comments below.
>>     
>
> I agree with Jouni. We definitely want similar feature but it needs to be
> carefully designed (and no, we are not limited by the limitations of WE).
> I'm not going to apply the patch.
>
>  Jiri
>
>   
I can not see how does it break per-STA TX rate limit, especially 
PRISM2_HOSTAPD_SET_RATE_SETS almost doing the same thing. I am not saying
the patch is correct I just want to know how to fix it to get it in.
Mohamed
