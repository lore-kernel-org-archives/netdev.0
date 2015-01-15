From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH RESEND 2/2] wlcore: align member-assigns in a structure-copy block
Date: Thu, 15 Jan 2015 15:23:41 +0200
Message-ID: <87twzsqisi.fsf@kamboji.qca.qualcomm.com>
References: <1420394427-19509-1-git-send-email-me@mortis.eu>
	<1420659525-22975-1-git-send-email-me@mortis.eu>
	<1420659525-22975-2-git-send-email-me@mortis.eu>
	<87vbkfga32.fsf@kamboji.qca.qualcomm.com>
	<CAB3XZEcm4+=dYC-8_m_7YRdET_wPkWUYHcDuy9mCKdxkCFEnQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giel van Schijndel <me@mortis.eu>,
	LKML <linux-kernel@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arik Nemtsov <arik@wizery.com>,
	"open list\:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	"open list\:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: Eliad Peller <eliad@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB3XZEcm4+=dYC-8_m_7YRdET_wPkWUYHcDuy9mCKdxkCFEnQA@mail.gmail.com>
	(Eliad Peller's message of "Sun, 11 Jan 2015 12:22:49 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eliad Peller <eliad@wizery.com> writes:

> On Fri, Jan 9, 2015 at 7:03 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
>> Giel van Schijndel <me@mortis.eu> writes:
>>
>>> This highlights the differences (e.g. the bug fixed in the previous
>>> commit).
>>>
>>> Signed-off-by: Giel van Schijndel <me@mortis.eu>
>>> ---
>>>  drivers/net/wireless/ti/wlcore/acx.c | 22 +++++++++++-----------
>>>  1 file changed, 11 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
>>> index f28fa3b..93a2fa8 100644
>>> --- a/drivers/net/wireless/ti/wlcore/acx.c
>>> +++ b/drivers/net/wireless/ti/wlcore/acx.c
>>> @@ -1715,17 +1715,17 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
>>>               goto out;
>>>       }
>>>
>>> -     acx->recover_time = cpu_to_le32(conf->recover_time);
>>> -     acx->hangover_period = conf->hangover_period;
>>> -     acx->dynamic_mode = conf->dynamic_mode;
>>> -     acx->early_termination_mode = conf->early_termination_mode;
>>> -     acx->max_period = conf->max_period;
>>> -     acx->min_period = conf->min_period;
>>> -     acx->increase_delta = conf->increase_delta;
>>> -     acx->decrease_delta = conf->decrease_delta;
>>> -     acx->quiet_time = conf->quiet_time;
>>> -     acx->increase_time = conf->increase_time;
>>> -     acx->window_size = conf->window_size;
>>> +     acx->recover_time               = cpu_to_le32(conf->recover_time);
>>> +     acx->hangover_period            = conf->hangover_period;
>>> +     acx->dynamic_mode               = conf->dynamic_mode;
>>> +     acx->early_termination_mode     = conf->early_termination_mode;
>>> +     acx->max_period                 = conf->max_period;
>>> +     acx->min_period                 = conf->min_period;
>>> +     acx->increase_delta             = conf->increase_delta;
>>> +     acx->decrease_delta             = conf->decrease_delta;
>>> +     acx->quiet_time                 = conf->quiet_time;
>>> +     acx->increase_time              = conf->increase_time;
>>> +     acx->window_size                = conf->window_size;
>>
>> I would like to get an ACK from one of the wlcore developers if I should
>> apply this (or not).
>
> I don't have a strong opinion here. However, it looks pretty much
> redundant to take a random blob (which was just fixed by a correct
> patch) and re-indent it. The rest of the file doesn't follow this
> style, so i don't see a good reason to apply it here.

Yeah, this should be a driver decision and not just a single change in
one function. Hence I'm dropping patch 2.

-- 
Kalle Valo
