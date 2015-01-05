From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: wireless: rtlwifi: btcoexist: halbtc8821a2ant:
 Remove some unused functions
Date: Mon, 5 Jan 2015 15:05:23 +1100
Message-ID: <CAGRGNgWbTv7Sv0sZR_VB7goy-U0cjUAFNgBm_okiajSPBK+SNg@mail.gmail.com>
References: <1420230361-1862-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
 <54A786A4.2050202@lwfinger.net> <CAKXHbyOYO29uKA127qyYrCfpgQ2zoqBS9rAJME513oZ8JVdOug@mail.gmail.com>
 <54A9ECC7.6040900@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54A9ECC7.6040900-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Larry,

On Mon, Jan 5, 2015 at 12:45 PM, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote:
> On 01/03/2015 06:03 AM, Rickard Strandqvist wrote:
>>
>> 2015-01-03 7:05 GMT+01:00 Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>:
>>
>>> On 01/02/2015 02:26 PM, Rickard Strandqvist wrote:
>>>
>>>> Removes some functions that are not used anywhere:
>>>> ex_halbtc8821a2ant_periodical() ex_halbtc8821a2ant_halt_notify()
>>>> ex_halbtc8821a2ant_bt_info_notify()
>>>> ex_halbtc8821a2ant_special_packet_notify()
>>>> ex_halbtc8821a2ant_connect_notify() ex_halbtc8821a2ant_scan_notify()
>>>> ex_halbtc8821a2ant_lps_notify() ex_halbtc8821a2ant_ips_notify()
>>>> ex_halbtc8821a2ant_display_coex_info() ex_halbtc8821a2ant_init_coex_dm()
>>>> ex_halbtc8821a2ant_init_hwconfig()
>>>>
>>>> This was partially found by using a static code analysis program called
>>>> cppcheck.
>>>>
>>>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@
>>>> spectrumdigital.se>
>>>>
>>>
>>> I know that you have been told that including "net: wireless:" in the
>>> subject line is discouraged. Please do not do this again. The staging
>>> directory is different as GregKH uses "staging:" in the subject to route
>>> patches, but wireless does not.
>>>
>>> As to the patch, NACK for the simple reason that I am currently working
>>> on
>>> a number of changes to btcoexist. Some of these routines may end up being
>>> removed, but others will not. Having your patch remove them, and one of
>>> mine adding them back just constitutes a lot of churning of the source.
>>> In
>>> addition, it greatly increases the probability of the source trees
>>> becoming
>>> unsynchronized and getting merge conflicts.
>>>
>>> Larry
>>>
>>>
>>
>> Hi Larry
>>
>> I do not recognize that there has been no diskution on the subject of
>> "net:
>> wireless:"
>> I use some sed call for this, so it's easy to fix. You want the "net:
>> wireless:" part completely erased then?
>> I check in Documentation/ but find any clear info for this.
>>
>> Sorry for the patch, is there any way for me to see that this is something
>> that is being worked on?
>
>
> These patches are the result of private communications between the Realtek
> engineers and me. The only publication is in the "rock" branch of the git
> repo at http://github.com/lwfinger/rtlwifi_new.git.
>
> I do not understand the "use of some 'sed' call". If you edit the source and
> add it to the git repo with the add and commit operations, then format-patch
> gives you exactly what you need, and send-email does that operation.

I suspect he means how he makes the subject lines. I'm guessing something like:

echo $PATH | sed 's/^.*\/drivers\///;s/\//: /;s/\.c$/: Remove some
unused functions/;'

Thanks,

-- 
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
