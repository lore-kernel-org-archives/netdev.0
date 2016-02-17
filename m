From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 7/8] net: ixgbe: add support for tc_u32
 offload
Date: Wed, 17 Feb 2016 06:47:15 -0500
Message-ID: <56C45DC3.1050607@mojatatu.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051853.17139.76889.stgit@john-Precision-Tower-5810>
 <56C456C6.60308@mojatatu.com> <20160217114204.GI2213@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, amir@vadai.me,
	davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33195 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161224AbcBQLrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 06:47:18 -0500
Received: by mail-io0-f178.google.com with SMTP id z135so34126912iof.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 03:47:17 -0800 (PST)
In-Reply-To: <20160217114204.GI2213@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 06:42 AM, Jiri Pirko wrote:
> Wed, Feb 17, 2016 at 12:17:26PM CET, jhs@mojatatu.com wrote:
>> On 16-02-17 12:18 AM, John Fastabend wrote:

>>
>> Note: i dont see anything that says "hw". Are you delegating ht 0x800
>> for h/w only? It is the default ht; so may not be the best choice.
>
> That is not implemented in this patchset. hw/sw/hwsw flag will be done
> in a follow up. So far, the user has only possibility to enable/disable
> the whole thing by ethtool feature flag.

[..]
>> All looks cool but I am just worried about the lack of intent that
>> something needs to go to hw vs sw. Other worry:
>> What happens when things fail to install in hw?
>
> Silently fail. I believe that this should be handled in the same
> follow-up I referred to above.
>

I can live with the above. John, please consider my comments when
sending next update.
So only outstanding issue is you need to fix that NEW with REPLACE
in patch 3.

For this patch:
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
