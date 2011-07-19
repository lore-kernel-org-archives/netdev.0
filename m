From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: ath: Unable to reset channel (2412 MHz), reset status -5
Date: Tue, 19 Jul 2011 09:01:30 -0700
Message-ID: <4E25AA5A.6070709@gmail.com>
References: <4E252076.1050309@gmail.com>	<CAD2nsn12vOXv-msWR+GF7edz3Q26P-pb4H-SO4rf2RHjC7mG+w@mail.gmail.com>	<4E2525BA.4090902@gmail.com>	<CAD2nsn3ifSMa_eFr2vQ0VVF9Ga-0VD3YB_beb28r+eoAHKv4kQ@mail.gmail.com>	<4E25A1E3.9080707@gmail.com> <CAD2nsn1xEB-e33_wrGqLETZ4MwFy12gtyawtg5XHLH0=-9vs2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mohammed Shafi <shafi.wireless@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD2nsn1xEB-e33_wrGqLETZ4MwFy12gtyawtg5XHLH0=-9vs2w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/19/2011 08:49 AM, Mohammed Shafi wrote:
> On Tue, Jul 19, 2011 at 8:55 PM, Justin P. Mattock
> <justinmattock@gmail.com>  wrote:
>> On 07/18/2011 11:46 PM, Mohammed Shafi wrote:
>>>
>>> On Tue, Jul 19, 2011 at 12:05 PM, Justin P. Mattock
>>> <justinmattock@gmail.com>    wrote:
>>>>
>>>> On 07/18/2011 11:25 PM, Mohammed Shafi wrote:
>>>>>
>>>>> On Tue, Jul 19, 2011 at 11:43 AM, Justin P. Mattock
>>>>> <justinmattock@gmail.com>      wrote:
>>>>>>
>>>>>> seems with the latest Mainline I am getting the ath9k carpping out
>>>>>> after
>>>>>> a
>>>>>> while of streaming(dmesg below)..:
>>>>>> http://fpaste.org/D7wM/
>>>>>>
>>>>>> will try a bisect if I have the time..
>>>>>
>>>>> I will try to recreate here with 3.0.0-rc7-wl, we can get more
>>>>> information by ath9k debug=0xffffffff.
>>>>> thanks.
>>>>>
>>>>
>>>> cool!
>>>> seems to fire off randomly over here.
>>>
>>> I have got AR5416, will try with that.
>>>
>>
>> I can try the bisect, but might take a while, since external
>> activities(job). Seems this is just starting i.g. with
>> 3.0.0-rc1 I never saw this, but with 3.0.0-rc7-00125-gf560f66
>> its making noise.
>
> I am unable to get this problem in my AR5416 :( will also try
> tomorrow. I am using the card for browsing etc.
> recently there were patches for hardware code changes.
> just a guess, please check does this patch helps(or is it already
> there). i think this will be called via
> ath_set_channel->ath9k_hw_reset->ath9k_hw_init_bb and may be
> https://patchwork.kernel.org/patch/957902/

I am not seeing this in: ar5008_hw_init_bb
will apply this to the current Mainline when I get the chance and run 
the system to see if I get this firing off.
(as for what I have, and was doing:(OS fedora 15)simply streaming radio 
with clients running in the background twitter, facebook, thunderbird

Justin P. Mattock
