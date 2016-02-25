From: Diego Viola <diego.viola@gmail.com>
Subject: Re: [PATCH v3] net: jme: fix suspend/resume on JMC260
Date: Thu, 25 Feb 2016 12:38:57 -0300
Message-ID: <CA+ToGPGFVhXQ5+VYu5Rq4gJ4vLHjYacnPdu5W2GCgciAyL15JA@mail.gmail.com>
References: <1456239844-4109-1-git-send-email-diego.viola@gmail.com>
	<20160224.235856.242530723940439026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, richard.weinberger@gmail.com,
	pavel@ucw.cz, rjw@rjwysocki.net, valdis.kletnieks@vt.edu
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160224.235856.242530723940439026.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 25, 2016 at 1:58 AM, David Miller <davem@davemloft.net> wrote:
> From: Diego Viola <diego.viola@gmail.com>
> Date: Tue, 23 Feb 2016 12:04:04 -0300
>
>> The JMC260 network card fails to suspend/resume because the call to
>> jme_start_irq() was too early, moving the call to jme_start_irq() after
>> the call to jme_reset_link() makes it work.
>>
>> Prior this change suspend/resume would fail unless /sys/power/pm_async=0
>> was explicitly specified.
>>
>> Relevant bug report: https://bugzilla.kernel.org/show_bug.cgi?id=112351
>>
>> Signed-off-by: Diego Viola <diego.viola@gmail.com>
>
> Applied and queued up for -stable, thanks.

Thanks.

Diego
