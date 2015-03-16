From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next] switchdev: call bridge setlink/dellink ndos
 recursively
Date: Mon, 16 Mar 2015 15:08:32 -0700
Message-ID: <55075460.9040408@gmail.com>
References: <1426515774-21038-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com,
	roopa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33804 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934456AbbCPWIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 18:08:43 -0400
Received: by oier21 with SMTP id r21so50348454oie.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 15:08:42 -0700 (PDT)
In-Reply-To: <1426515774-21038-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2015 07:22 AM, Jiri Pirko wrote:
> There has been a discussion about if it's better to let masters to
> propagate call down themself or if its better just blindly go down and
> try to call ndo on every lower netdev. Turned out that more people (me
> not included) like the second option better.
>
> This patch changes bridge setlink/dellink in that direction.
> Sorry Roopa for forcing you to do it the way I liked initially.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Hi Jiri,

I'm going to ask the dumb question here because it wasn't clear from
the emails I could dredge up.

Why do you want to do this? Can you add it to the commit message so
in the future it is clear. Specifically what does it mean to propagate
these calls down? Can you give a stacked example?

Thanks,
John

-- 
John Fastabend         Intel Corporation
