From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net-next 1/4] net: Introduce psample, a new genetlink
 channel for packet sampling
Date: Mon, 23 Jan 2017 15:57:50 -0800
Message-ID: <20170123155750.22f4b323@xeon-e3>
References: <1485085487-2652-1-git-send-email-jiri@resnulli.us>
        <1485085487-2652-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        xiyou.wangcong@gmail.com, linux@roeck-us.net,
        roopa@cumulusnetworks.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33938 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751786AbdAWX6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 18:58:50 -0500
Received: by mail-pg0-f47.google.com with SMTP id 14so48984473pgg.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 15:57:58 -0800 (PST)
In-Reply-To: <1485085487-2652-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Jan 2017 12:44:44 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> +static LIST_HEAD(psample_groups_list);
> +static DEFINE_SPINLOCK(psample_groups_lock);
> +

Why not a mutex? You aren't acquiring this in IRQ context?
