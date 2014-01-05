From: Asi Lichtenstein <asili22@gmail.com>
Subject: Re: How to add IPv6 multiple routing tables support to 2.6.16.26 kernel
Date: Sun, 5 Jan 2014 13:33:05 +0200
Message-ID: <CAMBtn_3=6-W0VG2oxBt6SUJ6ead0ao4oV49K8w4oSNNGu190mw@mail.gmail.com>
References: <CAMBtn_2fjONQk0aO6MBy3j9X__78CTon_aYzJWCjouKnZDXEMw@mail.gmail.com>
	<20140104133417.5d67c179@nehalam.linuxnetplumber.net>
	<CAMBtn_3gFon_Qdrnwfxpo8mXtK502hLDBQc9hf8_RFYLpfcSuA@mail.gmail.com>
	<CAMBtn_0TGndWf4zv783qEBe8YHWK6g0a_=QM_JoneavX7f3RTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:51299 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbaAELdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 06:33:06 -0500
Received: by mail-ob0-f174.google.com with SMTP id wn1so17209687obc.19
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 03:33:05 -0800 (PST)
In-Reply-To: <CAMBtn_0TGndWf4zv783qEBe8YHWK6g0a_=QM_JoneavX7f3RTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I know that this kernel is way too long but this is something that I
can't change.
It is not up to me to decide on kernel upgrade.

I was talking about IPv6 multiple route tables.
This is something that was added later in:
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c71099acce933455123ee505cc75964610a209ad
I've posted this thread to help me finding this patch:
http://thread.gmane.org/gmane.linux.network/41149

I could not find it anywhere, the link for the git changeset is broken.

I would appreciate any help with this one.

Thanks

On Sun, Jan 5, 2014 at 1:32 PM, Asi Lichtenstein <asili22@gmail.com> wrote:
> I know that this kernel is way too long but this is something that I can't
> change.
> It is not up to me to decide on kernel upgrade.
>
> I was talking about IPv6 multiple route tables.
> This is something that was added later in:
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c71099acce933455123ee505cc75964610a209ad
> I've posted this thread to help me finding this patch:
> http://thread.gmane.org/gmane.linux.network/41149
>
> I could not find it anywhere, the link for the git changeset is broken.
>
> I would appreciate any help with this one.
>
> Thanks
>
>
> On Sun, Jan 5, 2014 at 1:32 PM, Asi Lichtenstein <asili22@gmail.com> wrote:
>>
>> I know that this kernel is way too long but this is something that I can't
>> change.
>> It is not up to me to decide on kernel upgrade.
>>
>> I was talking about IPv6 multiple route tables.
>> This is something that was added later in:
>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c71099acce933455123ee505cc75964610a209ad
>> I've posted this thread to help me finding this patch:
>> http://thread.gmane.org/gmane.linux.network/41149
>>
>> I could not find it anywhere, the link for the git changeset is broken.
>>
>> I would appreciate any help with this one.
>>
>> Thanks
>>
>>
>> On Sat, Jan 4, 2014 at 11:34 PM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>>>
>>> On Thu, 2 Jan 2014 15:24:34 +0200
>>> Asi Lichtenstein <asili22@gmail.com> wrote:
>>>
>>> > Hi there,
>>> >
>>> > I need to add such support.
>>> > How would you recommend me adding such support?
>>> >
>>> > Is there a patch I could use?
>>> >
>>> > Thanks
>>> > --
>>> > To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> > the body of a message to majordomo@vger.kernel.org
>>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>> First, 2.6.16 is 8 years old.
>>> Second, by now there are 100's of known vulnerabilities; such a system
>>>  would be a sitting duck for remote exploitation.
>>> Third, multiple route tables in Linux was implemented much earlier
>>>  than that, back in the 2.4 development. It is probably in the 2.6.16
>>>  kernel. Most likely the vendor config or tools you have are broken
>>>  and don't allow access to it.
>>
>>
>
