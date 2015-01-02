From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: wireless: b43legacy: radio.c: Remove unused function
Date: Fri, 2 Jan 2015 22:34:47 +0100
Message-ID: <CACna6rxTYUWvxvu0rFydWxkjbYdHfhV=o+9A+ViCpbV-LFx7fw@mail.gmail.com>
References: <1420127170-28421-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<CACna6rznUcqGTK0t1k=kjn0NVLycq865780ozyB+VYu78d_BSg@mail.gmail.com>
	<CACna6rxbGRdw7XSYvHAJGxJvMVwjVbAL4ynBM3m9rNggh7gCVQ@mail.gmail.com>
	<CA+icZUWOXMEyobZkudW9BEfkaWFTXQL9XF26g7oJMCzt=4==6g@mail.gmail.com>
	<CAKXHbyO70WdWekSYCY9spMbX2+_kdKTp3JoreDKpCdUBzFwYqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sedat Dilek <sedat.dilek@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Network Development <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	b43-dev <b43-dev@lists.infradead.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:57471 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbABVes convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:34:48 -0500
In-Reply-To: <CAKXHbyO70WdWekSYCY9spMbX2+_kdKTp3JoreDKpCdUBzFwYqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 January 2015 at 18:46, Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se> wrote:
> 2015-01-02 13:14 GMT+01:00 Sedat Dilek <sedat.dilek@gmail.com>:
>>
>> On Fri, Jan 2, 2015 at 1:06 PM, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmai=
l.com> wrote:
>> > On 2 January 2015 at 13:05, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.=
com> wrote:
>> >> On 1 January 2015 at 16:46, Rickard Strandqvist
>> >> <rickard_strandqvist@spectrumdigital.se> wrote:
>> >>> Remove the function b43legacy_radio_set_tx_iq() that is not used
>> >>> anywhere.
>> >>>
>> >>> This was partially found by using a static code analysis program
>> >>> called cppcheck.
>> >>
>> >> It seems to be for A-PHY based hardware (with 0x2060 radio id) wh=
ich
>> >> is not handled by b43legacy. Should be safe to drop this code (we
>> >> won't likely need it).
>> >>
>> >> Ack
>> >
>> > For future, we prefix patches with just a driver name. So this cou=
ld
>> > be simply called
>> > b43legacy: radio.c: Remove unused function
>> >
>>
>> Alternatively...
>>
>> "b43legacy: Remove unused function in radio.c"
>>
>> BTW, as Arnd Bergmann pointed out [1] how did you test with cppcheck
>> to get such stuff?
>>
>> - Sedat -
>>
>> [1] https://lkml.org/lkml/2015/1/2/51
>
>
>
> Hi Rafal and Sedat
>
> Rafal do you mean I should remove the entire b43legacy part?

1) I gave you Ack for the changes
2) You could drop "net: wireless: " or better use something Sedat propo=
sed

--=20
Rafa=C5=82
