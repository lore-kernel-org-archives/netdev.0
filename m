From: Nick Kossifidis <mickflemm@gmail.com>
Subject: Re: ath5k regression associating with APs in 2.6.38
Date: Wed, 4 May 2011 23:09:03 +0300
Message-ID: <BANLkTimEmBRyxbZgffJMrH4TTc4f6peuTg__1380.58396191827$1304539774$gmane$org@mail.gmail.com>
References: <20110504153819.GA4551@thinkpad-t410>
	<20110504172716.GC18541@tuxdriver.com>
	<20110504192639.GB4551@thinkpad-t410>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@b
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47412 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab1EDUJE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:09:04 -0400
In-Reply-To: <20110504192639.GB4551@thinkpad-t410>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/4 Seth Forshee <seth.forshee@canonical.com>:
> On Wed, May 04, 2011 at 01:27:17PM -0400, John W. Linville wrote:
>> On Wed, May 04, 2011 at 10:38:19AM -0500, Seth Forshee wrote:
>> > I've been investigating some reports of a regression in associatin=
g with
>> > APs with AR2413 in 2.6.38. Association repeatedly fails with some
>> > "direct probe to x timed out" messages (see syslog excerpt below),
>> > although it will generally associate eventually, after many tries.
>> >
>> > Bisection identifies 8aec7af (ath5k: Support synth-only channel ch=
ange
>> > for AR2413/AR5413) as offending commit. Prior to this commit there=
 are
>> > no direct probe messages at all in the logs. I've also found that
>> > forcing fast to false at the top of ath5k_hw_reset() fixes the iss=
ue.
>> > I'm not sure what the connection is between this commit and the
>> > timeouts. Any suggestions?
>>
>> Have you tried reverting that commit on top of 2.6.38? =C2=A0Can you
>> recreate the issue with 2.6.39-rc6 (or later)?
>
> I started to revert that commit, but it wasn't straight-forward due t=
o
> later changes. Forcing fast to false in ath5k_hw_reset() acts as a
> functional revert of sorts since that should force it back to a full
> reset for all channel changes, and it's much simpler than working out
> the right way to revert the commit. I think the results suggest stron=
gly
> that a revert is likely to fix the problem. I can finish the work to
> revert if you'd still like to see the results.
>
> Testing a previous .39-rc kernel still exhibited the failure. I don't
> recall which one it was and apparently forgot to make note of it. I'l=
l
> request testing against rc6.
>
> Thanks,
> Seth
>

Do you get scan results ?
Can you enable ATH5K_DEBUG_RESET and see what you get ?

--=20
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
