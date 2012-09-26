From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 5/5] smsc95xx: enable power saving mode during system suspend
Date: Wed, 26 Sep 2012 18:17:51 +0200
Message-ID: <87mx0c92s0.fsf@nemi.mork.no>
References: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
	<1348663224-30403-6-git-send-email-steve.glendinning@shawell.net>
	<87y5jw982o.fsf@nemi.mork.no>
	<CAKh2mn5tKowqjbvgWDSz52UF9qY9_ysAb23Pb-M_3wvCG=_R6w@mail.gmail.com>
	<87txuk9453.fsf@nemi.mork.no>
	<CAKh2mn4XLCPfTFySEvtZc56J+WM863JtnsjF2D-RyDJatoyAww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:46350 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755926Ab2IZQRy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 12:17:54 -0400
In-Reply-To: <CAKh2mn4XLCPfTFySEvtZc56J+WM863JtnsjF2D-RyDJatoyAww@mail.gmail.com>
	(Steve Glendinning's message of "Wed, 26 Sep 2012 16:58:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning <steve@shawell.net> writes:

>>> I hadn't thought that was a situation that could arise, is it?  Wou=
ld
>>> this happen if the USB device was removed during suspend?
>>
>> No, it should not happen.  But then, why test at all?
>
> I thought it was common practice to add these tests to document an
> assumption the developer made that later code relies on?  I had
> assumed that the !dev condition should not be possible, hence the
> simple BUG test.  If it is possible then I agree - I definitely need
> to handle this more gracefully.
>
> In this case, asserting that dev is not NULL will make the code fail
> loudly there instead of a few lines down when the netdev_info call
> dereferences dev->net.  Either way something bad will happen!

Yes, but you are a lot less likely to know about it if you BUG out.  Th=
e
user will be left with no other choice than hitting reset or poweroff.
What's the point of that?

If your driver crashes but the machine is left running, then the user
may forward the Oops to you.  That's much more useful.


Bj=C3=B8rn
