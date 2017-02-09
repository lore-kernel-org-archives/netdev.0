From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 5/6] sched: add missing curly braces in else
 branch in tc_ctl_tfilter
Date: Thu, 9 Feb 2017 22:45:52 +0100
Message-ID: <20170209214552.GA1995@nanopsycho>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
 <1486647540-14656-6-git-send-email-jiri@resnulli.us>
 <0158ade7-fdf9-8aaf-4573-deb844a0cb92@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, mlxsw@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36835 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753723AbdBIVp4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:45:56 -0500
Received: by mail-wm0-f68.google.com with SMTP id r18so4818297wmd.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 13:45:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <0158ade7-fdf9-8aaf-4573-deb844a0cb92@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 09, 2017 at 07:27:10PM CET, jhs@mojatatu.com wrote:
>On 17-02-09 08:38 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Curly braces need to be there, for stylistic reasons.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  net/sched/cls_api.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>> index f44378c..48864ad 100644
>> --- a/net/sched/cls_api.c
>> +++ b/net/sched/cls_api.c
>> @@ -315,8 +315,9 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
>>  					err = -EINVAL;
>>  					goto errout;
>>  				}
>> -			} else
>> +			} else {
>>  				tp = NULL;
>> +			}
>>  			break;
>>  		}
>>  	}
>> 
>
>Jiri, shall we engage in a long discussion about which rule says that
>you can put braces around one line branching? ;->

scripts/checkpatch.pl :)


>
>Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
>cheers,
>jamal
