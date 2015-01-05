From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcm80211: brcmsmac: dma: Remove some unused functions
Date: Mon, 5 Jan 2015 12:06:42 +0100
Message-ID: <54AA7042.50207@broadcom.com>
References: <1420332469-5907-1-git-send-email-rickard_strandqvist@spectrumdigital.se>	<54A8DBF4.4050202@lwfinger.net>	<CAKXHbyN6LH_pFw1uoLXRzgJv-NcjbTLJvMZXfwYXDwuk9QDszA@mail.gmail.com> <871tn933jc.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Brett Rudley <brudley@broadcom.com>,
	"Hante Meuleman" <meuleman@broadcom.com>,
	Fabian Frederick <fabf@skynet.be>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <871tn933jc.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/15 11:49, Kalle Valo wrote:
> Rickard Strandqvist<rickard_strandqvist@spectrumdigital.se>  writes:
>
>> As I hope you can see I have made some changes regarding the
>> subject-line. Thought it was an advantage to be able to see which file
>> I actually removed something from. There seems to be a big focus on
>> getting right on subject-line right in recent weeks.
>>
>> I wonder why there is a script that takes a file name, and respond
>> with an appropriate subject line?

Is there a script for this? Anyway, I would say driver name is enough. 
Enough about the subject line ;-) I would like to give some general 
remarks as you seem to touch a lot of kernel code. First off, I think it 
is good to remove unused stuff. However, I would like some more 
explanation on your methodology apart from "partially found by using a 
static code analysis program". So a cover-letter explaining that would 
have been nice (maybe still is). Things like Kconfig option can affect 
whether function are used or not so how did you cover that.

Regards,
Arend

> I don't think you can really automate this as some drivers do this a bit
> differently. You always need to manually check the commit log.
>
>> But ok, I change my script accordingly. Should I submit the patch again?
>
> Yes, please resubmit.
>
