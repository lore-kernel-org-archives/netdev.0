From: Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: wireless: b43legacy: radio.c: Remove unused function
Date: Sat, 3 Jan 2015 14:19:35 +0100
Message-ID: <CA+icZUUJfemKC85=p7Huyw7xwfUdXBhePseJCnUKLx9edgpT4w@mail.gmail.com>
References: <1420127170-28421-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<CACna6rznUcqGTK0t1k=kjn0NVLycq865780ozyB+VYu78d_BSg@mail.gmail.com>
	<CACna6rxbGRdw7XSYvHAJGxJvMVwjVbAL4ynBM3m9rNggh7gCVQ@mail.gmail.com>
	<CA+icZUWOXMEyobZkudW9BEfkaWFTXQL9XF26g7oJMCzt=4==6g@mail.gmail.com>
	<CAKXHbyO70WdWekSYCY9spMbX2+_kdKTp3JoreDKpCdUBzFwYqw@mail.gmail.com>
	<CACna6rxTYUWvxvu0rFydWxkjbYdHfhV=o+9A+ViCpbV-LFx7fw@mail.gmail.com>
	<CAKXHbyMqTk=k7eieBNtAD+n6+4w3weL82twHBo-o8ebm_3+wvg@mail.gmail.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	b43-dev <b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKXHbyMqTk=k7eieBNtAD+n6+4w3weL82twHBo-o8ebm_3+wvg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 3, 2015 at 1:28 PM, Rickard Strandqvist
<rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org> wrote:
> 2015-01-02 22:34 GMT+01:00 Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
:
>>
>> On 2 January 2015 at 18:46, Rickard Strandqvist
>> <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org> wrote:
>> > 2015-01-02 13:14 GMT+01:00 Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>> >>
>> >> On Fri, Jan 2, 2015 at 1:06 PM, Rafa=C5=82 Mi=C5=82ecki <zajec5@g=
mail.com> wrote:
>> >> > On 2 January 2015 at 13:05, Rafa=C5=82 Mi=C5=82ecki <zajec5@gma=
il.com> wrote:
>> >> >> On 1 January 2015 at 16:46, Rickard Strandqvist
>> >> >> <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org> wrote:
>> >> >>> Remove the function b43legacy_radio_set_tx_iq() that is not u=
sed
>> >> >>> anywhere.
>> >> >>>
>> >> >>> This was partially found by using a static code analysis prog=
ram
>> >> >>> called cppcheck.
>> >> >>
>> >> >> It seems to be for A-PHY based hardware (with 0x2060 radio id)=
 which
>> >> >> is not handled by b43legacy. Should be safe to drop this code =
(we
>> >> >> won't likely need it).
>> >> >>
>> >> >> Ack
>> >> >
>> >> > For future, we prefix patches with just a driver name. So this =
could
>> >> > be simply called
>> >> > b43legacy: radio.c: Remove unused function
>> >> >
>> >>
>> >> Alternatively...
>> >>
>> >> "b43legacy: Remove unused function in radio.c"
>> >>
>> >> BTW, as Arnd Bergmann pointed out [1] how did you test with cppch=
eck
>> >> to get such stuff?
>> >>
>> >> - Sedat -
>> >>
>> >> [1] https://lkml.org/lkml/2015/1/2/51
>> >
>> >
>> >
>> > Hi Rafal and Sedat
>> >
>> > Rafal do you mean I should remove the entire b43legacy part?
>>
>> 1) I gave you Ack for the changes
>> 2) You could drop "net: wireless: " or better use something Sedat pr=
oposed
>>
>> --
>> Rafa=C5=82
>
>
>
> Hi
>
> Nice, yes I miss the Ack :)
>
> I just got one more complaining about my subject-line in "net: wirele=
ss: "
> I use some sed call for this, so it's easy to fix. I will now remove =
that
> part hereinafter.
> I check in Documentation/ but did not find any clear info for this.
>

The easiest way to make (sub)maintainers happy is to check the git-log.=
=2E.

$ git log --oneline /path/to/file

=2E..and look how other contributors labeled their patches.

[1] is the 1st address to look at on how to submit patches to Linux-ker=
nel.
To promote the good work of Greg, see [2,3] for a video and tutorial
on that topic, too.

- Sedat -

[1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree=
/Documentation/SubmittingPatches
[2] https://www.youtube.com/watch?v=3DXXix80GCvpo
[3] https://github.com/gregkh/kernel-tutorial
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
