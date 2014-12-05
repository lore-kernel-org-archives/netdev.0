From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH iproute2 REGRESSIONS v2] ss: Fix layout/output issues
 introduced by regression
Date: Fri, 05 Dec 2014 20:22:40 +0300
Message-ID: <5481E9E0.6080809@cogentembedded.com>
References: <1417791796-7739-1-git-send-email-vadim4j@gmail.com> <5481E77C.7070102@cogentembedded.com> <20141205170641.GA23226@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:53005 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbaLERWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 12:22:44 -0500
Received: by mail-lb0-f173.google.com with SMTP id z12so913077lbi.18
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 09:22:43 -0800 (PST)
In-Reply-To: <20141205170641.GA23226@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2014 08:06 PM, vadim4j@gmail.com wrote:

>   [...]
>>> @@ -2912,11 +2910,12 @@ static void netlink_show_one(struct filter *f,
>>>   		printf("%-*s ", state_width, "UNCONN");
>>>   	printf("%-6d %-6d ", rq, wq);
>>>
>>> -	if (resolve_services)
>>> -	{
>>> +	if (resolve_services) {
>>>   		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
>>>   					sizeof(prot_name)));
>>> -	}
>>> +	} else
>>> +		printf("%*d:", addr_width, prot);
>>> +

>>     Extra empty line hardly needed here. And if iproute2 follows the Linux
>> kernel style, {} should be used in all arms of the *if* statement (since
>> it's used in one case).

>>>
>>>   	if (pid == -1) {
>>>   		printf("%-*s ", serv_width, "*");

> You mean change to this ?

> 	if (resolve_services) {
>   		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
>   					sizeof(prot_name)));
> 	} else {
> 		printf("%*d:", addr_width, prot);
>          }

    Yes (but indent } with tab please).

> Thanks,

WBR, Sergei
