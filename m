From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 7/8] net: ixgbe: add support for tc_u32 offload
Date: Wed, 17 Feb 2016 06:25:36 -0800
Message-ID: <56C482E0.2080200@gmail.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810> <20160217051853.17139.76889.stgit@john-Precision-Tower-5810> <56C456C6.60308@mojatatu.com> <20160217114204.GI2213@nanopsycho.orion> <56C45DC3.1050607@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35677 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161643AbcBQOZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 09:25:50 -0500
Received: by mail-pf0-f170.google.com with SMTP id c10so12757700pfc.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 06:25:50 -0800 (PST)
In-Reply-To: <56C45DC3.1050607@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 03:47 AM, Jamal Hadi Salim wrote:
> On 16-02-17 06:42 AM, Jiri Pirko wrote:
>> Wed, Feb 17, 2016 at 12:17:26PM CET, jhs@mojatatu.com wrote:
>>> On 16-02-17 12:18 AM, John Fastabend wrote:
> 
>>>
>>> Note: i dont see anything that says "hw". Are you delegating ht 0x800
>>> for h/w only? It is the default ht; so may not be the best choice.
>>
>> That is not implemented in this patchset. hw/sw/hwsw flag will be done
>> in a follow up. So far, the user has only possibility to enable/disable
>> the whole thing by ethtool feature flag.
> 
> [..]
>>> All looks cool but I am just worried about the lack of intent that
>>> something needs to go to hw vs sw. Other worry:
>>> What happens when things fail to install in hw?
>>
>> Silently fail. I believe that this should be handled in the same
>> follow-up I referred to above.
>>
> 
> I can live with the above. John, please consider my comments when
> sending next update.
> So only outstanding issue is you need to fix that NEW with REPLACE
> in patch 3.
> 

Perfect. I'm sending an update for patch 3 now and I'll carry all
your Acks forward thanks for the review Jamal.

> For this patch:
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> cheers,
> jamal
> 
> 
