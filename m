From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC] tbf: handle gso skbs properly
Date: Fri, 15 Feb 2013 15:28:47 +0100
Message-ID: <20130215142847.GA1543@minipsycho.orion>
References: <1360932297-6698-1-git-send-email-jiri@resnulli.us>
 <1360937929.6884.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:40663 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343Ab3BOO25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 09:28:57 -0500
Received: by mail-ee0-f50.google.com with SMTP id e51so1796987eek.9
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 06:28:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360937929.6884.82.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for review Eric. I will process your suggestions and submit the
patch.


Fri, Feb 15, 2013 at 03:18:49PM CET, eric.dumazet@gmail.com wrote:
>On Fri, 2013-02-15 at 13:44 +0100, Jiri Pirko wrote:
>> According to Eric's suggestion, when gso skb can't be sent in one mtu
>> time, resegment it.
>> 
>> Note that helper will be moved to sch_api.c probably so it can be used
>> by other code.
>> 
>> Also, I'm not sure similar patch to this can be done for act_police. I
>> have to look at that more closely.


Any idea how to fix this in act_police? I believe we can't use the same
approach since there is no queue there.

Thanks.

Jiri
