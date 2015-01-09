From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 03/11] net: flow_table: add apply action argument
 to tables
Date: Thu, 08 Jan 2015 22:17:12 -0800
Message-ID: <54AF7268.6010309@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194642.31070.14445.stgit@nitbit.x32> <20150108174151.GE1898@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, sfeldma@gmail.com, jhs@mojatatu.com,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:52445 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbbAIGRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 01:17:34 -0500
Received: by mail-ob0-f179.google.com with SMTP id va2so11768801obc.10
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 22:17:33 -0800 (PST)
In-Reply-To: <20150108174151.GE1898@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2015 09:41 AM, Jiri Pirko wrote:
> Wed, Dec 31, 2014 at 08:46:44PM CET, john.fastabend@gmail.com wrote:
>> Actions may not always be applied after exiting a table. For example
>> some pipelines may accumulate actions and then apply them at the end
>> of a pipeline.
>>
>> To model this we use a table type called APPLY. Tables who share an
>> apply identifier have their actions applied in one step.
>
> Why this is a separate patch? Perhaps this can be squashed to one of the
> previous ones?
>

Good point mostly an artefact of how the code evolved I'll push it
into on of the previous patches as you suggest.

Thanks,
John


-- 
John Fastabend         Intel Corporation
