From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 1/3] rtlwifi: btcoexist: Remove some unused functions
Date: Thu, 15 Jan 2015 15:49:33 +0200
Message-ID: <87twzsnogi.fsf@kamboji.qca.qualcomm.com>
References: <1420907079-27102-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<54B15D57.5060709@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Masanari Iida <standby24x7@gmail.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54B15D57.5060709@lwfinger.net> (Larry Finger's message of "Sat,
	10 Jan 2015 11:11:51 -0600")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger@lwfinger.net> writes:

> On 01/10/2015 10:24 AM, Rickard Strandqvist wrote:
>> Removes some functions that are not used anywhere:
>> ex_halbtc8821a1ant_periodical() ex_halbtc8821a1ant_pnp_notify()
>> ex_halbtc8821a1ant_halt_notify() ex_halbtc8821a1ant_bt_info_notify()
>> ex_halbtc8821a1ant_special_packet_notify() ex_halbtc8821a1ant_connect_notify()
>> ex_halbtc8821a1ant_scan_notify() ex_halbtc8821a1ant_lps_notify()
>> ex_halbtc8821a1ant_ips_notify() ex_halbtc8821a1ant_display_coex_info()
>> ex_halbtc8821a1ant_init_coex_dm() ex_halbtc8821a1ant_init_hwconfig()
>>
>> This was partially found by using a static code analysis program called cppcheck.
>>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
>
> NACK!!!!!!!!!
>
> I told you to stay away from these routines until I finish my update.
> Not only might you remove some functions that I will be needing later,
> but you run the risk of merge complications.
>
> Kalle: Please ignore EVERYTHING from this person. Obviously, he is
> incapable of understanding even the simplest instructions.

Yeah, I have to agree with that. I think he is just too fixated creating
the patches automatically.

I have dropped the patches.

-- 
Kalle Valo
