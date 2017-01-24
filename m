From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/4] net: Introduce psample, a new genetlink
 channel for packet sampling
Date: Tue, 24 Jan 2017 07:48:05 +0100
Message-ID: <20170124064805.GA1891@nanopsycho>
References: <1485085487-2652-1-git-send-email-jiri@resnulli.us>
 <1485085487-2652-2-git-send-email-jiri@resnulli.us>
 <20170123155750.22f4b323@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        xiyou.wangcong@gmail.com, linux@roeck-us.net,
        roopa@cumulusnetworks.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35233 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdAXGsI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 01:48:08 -0500
Received: by mail-wm0-f66.google.com with SMTP id d140so32333224wmd.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 22:48:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170123155750.22f4b323@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 24, 2017 at 12:57:50AM CET, stephen@networkplumber.org wrote:
>On Sun, 22 Jan 2017 12:44:44 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> +static LIST_HEAD(psample_groups_list);
>> +static DEFINE_SPINLOCK(psample_groups_lock);
>> +
>
>Why not a mutex? You aren't acquiring this in IRQ context?

Well, that is not argument for mutex. Mutex is much heavier and does not
need to be used when not necessary (like if you don't need to sleep).
