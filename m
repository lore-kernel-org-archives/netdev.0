From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 2/4] tc: m_ife: print IEEE ethertype format
Date: Mon, 28 Aug 2017 18:56:39 -0400
Message-ID: <51175933-03ea-2419-b871-e5e9a5955528@mojatatu.com>
References: <20170828190738.26829-1-aring@mojatatu.com>
 <20170828190738.26829-3-aring@mojatatu.com>
 <ff74308c-2fe9-7c73-6215-8a269ea1be5e@mojatatu.com>
 <20170828153734.4b32fa02@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <aring@mojatatu.com>, yotamg@mellanox.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:32981 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbdH1W4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:56:41 -0400
Received: by mail-io0-f180.google.com with SMTP id s101so9171123ioe.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 15:56:41 -0700 (PDT)
In-Reply-To: <20170828153734.4b32fa02@xeon-e3>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-28 06:37 PM, Stephen Hemminger wrote:
> On Mon, 28 Aug 2017 18:18:04 -0400

[..]
>>> @@ -125,7 +125,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
>>>    			NEXT_ARG();
>>>    			if (get_u16(&ife_type, *argv, 0))
>>>    				invarg("ife type is invalid", *argv);
>>> -			fprintf(stderr, "IFE type 0x%x\n", ife_type);
>>> +			fprintf(stderr, "IFE type 0x%04X\n", ife_type);
>>>    			user_type = 1;
>>>    		} else if (matches(*argv, "dst") == 0) {
>>>    			NEXT_ARG();
>>>    
>>
> 
> 
> For iproute commands the show output is supposed to match the corresponding set inputs.
> 

These were being printed at parse time ...

cheers,
jamal
