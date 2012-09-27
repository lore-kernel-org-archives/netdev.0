From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 5/5] smsc95xx: enable power saving mode during system suspend
Date: Thu, 27 Sep 2012 19:14:42 +0200
Message-ID: <87k3vfz8u5.fsf@nemi.mork.no>
References: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
	<1348663224-30403-6-git-send-email-steve.glendinning@shawell.net>
	<87y5jw982o.fsf@nemi.mork.no>
	<CAKh2mn5tKowqjbvgWDSz52UF9qY9_ysAb23Pb-M_3wvCG=_R6w@mail.gmail.com>
	<87txuk9453.fsf@nemi.mork.no>
	<CAKh2mn4XLCPfTFySEvtZc56J+WM863JtnsjF2D-RyDJatoyAww@mail.gmail.com>
	<87mx0c92s0.fsf@nemi.mork.no>
	<CAKh2mn5shRWNXzj0BotxqfM2EJUM9UBQfUsXVqdd63eiWo0S-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38639 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134Ab2I0ROq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 13:14:46 -0400
In-Reply-To: <CAKh2mn5shRWNXzj0BotxqfM2EJUM9UBQfUsXVqdd63eiWo0S-Q@mail.gmail.com>
	(Steve Glendinning's message of "Thu, 27 Sep 2012 09:04:51 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning <steve@shawell.net> writes:
> On 26 September 2012 17:17, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>> Yes, but you are a lot less likely to know about it if you BUG out. =
 The
>> user will be left with no other choice than hitting reset or powerof=
f.
>> What's the point of that?
>>
>> If your driver crashes but the machine is left running, then the use=
r
>> may forward the Oops to you.  That's much more useful.
>
> Good point, I hadn't considered that.
>
> So for user reportability am I better off to use WARN_ON in this case=
,
> or simply remove the check and let the null pointer dereference
> happen?

Exactly.  See also http://permalink.gmane.org/gmane.linux.kernel/136568=
9


Bj=C3=B8rn
