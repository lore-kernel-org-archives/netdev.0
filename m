From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcm80211: brcmsmac: dma: Remove some unused functions
Date: Wed, 7 Jan 2015 09:58:11 +0100
Message-ID: <54ACF523.2030706@broadcom.com>
References: <1420332469-5907-1-git-send-email-rickard_strandqvist@spectrumdigital.se> <54A8DBF4.4050202@lwfinger.net> <CAKXHbyN6LH_pFw1uoLXRzgJv-NcjbTLJvMZXfwYXDwuk9QDszA@mail.gmail.com> <871tn933jc.fsf@kamboji.qca.qualcomm.com> <54AA7042.50207@broadcom.com> <CAKXHbyNBV6=DPF4n0onzhEqAuS-PqLS5pwZj_OitRuYMvgpjvw@mail.gmail.com> <alpine.DEB.2.02.1501070726320.2058@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"Brett Rudley" <brudley@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Fabian Frederick <fabf@skynet.be>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1501070726320.2058@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/07/15 07:29, Julia Lawall wrote:
>
>
> On Wed, 7 Jan 2015, Rickard Strandqvist wrote:
>
>> 2015-01-05 12:06 GMT+01:00 Arend van Spriel<arend@broadcom.com>:
>>> On 01/05/15 11:49, Kalle Valo wrote:
>>>>
>>>> Rickard Strandqvist<rickard_strandqvist@spectrumdigital.se>   writes:
>>>>
>>>>> As I hope you can see I have made some changes regarding the
>>>>> subject-line. Thought it was an advantage to be able to see which file
>>>>> I actually removed something from. There seems to be a big focus on
>>>>> getting right on subject-line right in recent weeks.
>>>>>
>>>>> I wonder why there is a script that takes a file name, and respond
>>>>> with an appropriate subject line?
>>>
>>>
>>> Is there a script for this? Anyway, I would say driver name is enough.
>>> Enough about the subject line ;-) I would like to give some general remarks
>>> as you seem to touch a lot of kernel code. First off, I think it is good to
>>> remove unused stuff. However, I would like some more explanation on your
>>> methodology apart from "partially found by using a static code analysis
>>> program". So a cover-letter explaining that would have been nice (maybe
>>> still is). Things like Kconfig option can affect whether function are used
>>> or not so how did you cover that.
>>>
>>> Regards,
>>> Arend
>>>
>>>
>>>> I don't think you can really automate this as some drivers do this a bit
>>>> differently. You always need to manually check the commit log.
>>>>
>>>>> But ok, I change my script accordingly. Should I submit the patch again?
>>>>
>>>>
>>>> Yes, please resubmit.
>>>>
>>>
>>
>> Hi Arend
>>
>> Yes, a script that had been excellent, I think!
>> I have one as part of my git send-email script, until a week ago, it
>> was enough that I removed the "drivers/" and changed all "/" to ": "
>> I have now been expanded my sed pipe a lot (tell me if anyone is interested)
>> But now I've seen everything from uppercase and [DIR], etc.
>> So I can not understand how anyone should be able to get the right
>> name without a good help.
>>
>> Sure i like to share how I use cppcheck, but is very hesitant to write
>> this with each patch mails I send though!
>>
>> I run:
>> cppcheck --force --quiet --enable=all .
>>
>> Or a specific file instead of .
>>
>> This will include, among other things get a lot of error message such,
>> +4000 for the kernel.
>> (style) The function 'xxx' is never used
>>
>> For these I made a script that searched through all the files after
>> the function name (cppcheck missed a few). And save the rest so I go
>> through them and possibly send patches.
>
> I think that the question was about what methodology is cppcheck using to
> find the given issue.  But probably cppcheck is a black box that does
> whatever it does, so the user doesn't know what the rationale is.

That would have been nice, but I also wanted to know what his subsequent 
steps were to validate the output from cppcheck. I went through some 
cppcheck web pages, but they only elaborate on what is can do and not 
the how. But hey, it is an open-source tool so there is always the code 
to check.

> However, I think you mentioned that cppcheck found only some of the
> issues.  You could thus describe what was the methodology for finding the
> other ones.

Maybe upon removing an unused function it had a ripple effect on others 
becoming unused as well? Still this is speculating and with this kind of 
cleanup effort all over the place it is better to review the methodology.

Regards,
Arend

> julia
