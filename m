From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/2] devlink: add hardware messages tracing
 facility
Date: Tue, 12 Jul 2016 19:10:46 +0200
Message-ID: <20160712171046.GA1799@nanopsycho.orion>
References: <1468339504-27580-1-git-send-email-jiri@resnulli.us>
 <20160712123826.15a31a41@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, mingo@redhat.com,
	jolsa@kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36103 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbcGLRKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 13:10:51 -0400
Received: by mail-wm0-f65.google.com with SMTP id x83so2710449wma.3
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 10:10:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160712123826.15a31a41@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 12, 2016 at 06:38:26PM CEST, rostedt@goodmis.org wrote:
>On Tue, 12 Jul 2016 18:05:03 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Define a tracepoint and allow user to trace messages going to and from
>> hardware associated with devlink instance.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> v1->v2:
>> - Use EXPORT_TRACEPOINT_SYMBOL_GPL instead of a wrapper function
>>   as suggested by David Ahern and Steven Rostedt
>
>FYI, you can use the Suggested-by: tag too ;-)

Thought that the purpose of that tag is if someone suggested the whole
patch existence.

<snip>

>> +/* This part must be outside protection */
>> +#include <trace/define_trace.h>
>> +
>> +#else /* CONFIG_NET_DEVLINK */
>> +
>> +#if !defined(_TRACE_DEVLINK_H)
>> +#define _TRACE_DEVLINK_H
>
>Ah, I guess you do need header protection here.

Yes, you do.

>
>OK, looks good to me.
>
>Acked-by: Steven Rostedt <rostedt@goodmis.org>

Thanks Steven!
