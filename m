From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 6/6] sched: check negative err value to safe one
 level of indent
Date: Thu, 9 Feb 2017 13:32:21 -0500
Message-ID: <da6c4be4-e35c-1ea2-36f5-109ca0aa5bb6@mojatatu.com>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
 <1486647540-14656-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36764 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754048AbdBISc2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 13:32:28 -0500
Received: by mail-io0-f179.google.com with SMTP id j13so24716530iod.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 10:32:23 -0800 (PST)
In-Reply-To: <1486647540-14656-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-09 08:39 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> As it is more common, check err for !0. That allows to safe one level of
> indentation and makes the code easier to read. Also, make 'next' variable
> global in function as it is used twice.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

BTW: Another nice cleanup is to separate for better
readability/maintainability DEL/GET/NEW into
their own functions. GET/DEL are very close but sometimes are
slightly different - in the action code they are already breaking.

cheers,
jamal
