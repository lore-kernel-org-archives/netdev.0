From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: Re: [PATCH] brcm80211: brcmsmac: dma: Remove some unused functions
Date: Sun, 4 Jan 2015 13:43:59 +0100
Message-ID: <CAKXHbyN6LH_pFw1uoLXRzgJv-NcjbTLJvMZXfwYXDwuk9QDszA@mail.gmail.com>
References: <1420332469-5907-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<54A8DBF4.4050202@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>,
	Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54A8DBF4.4050202-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2015-01-04 7:21 GMT+01:00 Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>:
> On 01/03/2015 06:47 PM, Rickard Strandqvist wrote:
>>
>> Removes some functions that are not used anywhere:
>> dma_txflush() dma_txsuspended()
>>
>> This was partially found by using a static code analysis program called
>> cppcheck.
>>
>> Signed-off-by: Rickard Strandqvist
>> <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
>> ---
>>   drivers/net/wireless/brcm80211/brcmsmac/dma.c |   19 -------------------
>>   drivers/net/wireless/brcm80211/brcmsmac/dma.h |    2 --
>>   2 files changed, 21 deletions(-)
>
>
> Just because file dma.c is involved, it does not need to be, nor should it
> be in the subject line. You could specify the driver names in the file tree
> after wireless. In this instance, one possible subject would be "brcm80211:
> brcmsmac: Remove some unused functions". On the other hand, if you look at
> "git log" to see past patches, the driver maintainers even leave off the
> brcm80211 part, thus to match them, the subject should be "brcmsmac: Remove
> some unused functions".
>
> As was suggested earlier, you need to look at the precedents. Keeping a
> uniform method of patch naming helps when looking for patches in the git
> log.
>
> Larry
>


Hi Larry

As I hope you can see I have made some changes regarding the
subject-line. Thought it was an advantage to be able to see which file
I actually removed something from.
There seems to be a big focus on getting right on subject-line right
in recent weeks.

I wonder why there is a script that takes a file name, and respond
with an appropriate subject line?

But ok, I change my script accordingly. Should I submit the patch again?


Kind regards
Rickard Strandqvist
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
