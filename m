From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 5/5] smsc95xx: enable power saving mode during system suspend
Date: Thu, 27 Sep 2012 09:04:51 +0100
Message-ID: <CAKh2mn5shRWNXzj0BotxqfM2EJUM9UBQfUsXVqdd63eiWo0S-Q@mail.gmail.com>
References: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
	<1348663224-30403-6-git-send-email-steve.glendinning@shawell.net>
	<87y5jw982o.fsf@nemi.mork.no>
	<CAKh2mn5tKowqjbvgWDSz52UF9qY9_ysAb23Pb-M_3wvCG=_R6w@mail.gmail.com>
	<87txuk9453.fsf@nemi.mork.no>
	<CAKh2mn4XLCPfTFySEvtZc56J+WM863JtnsjF2D-RyDJatoyAww@mail.gmail.com>
	<87mx0c92s0.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:50764 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515Ab2I0IE4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 04:04:56 -0400
Received: by oagh16 with SMTP id h16so1497845oag.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 01:04:51 -0700 (PDT)
In-Reply-To: <87mx0c92s0.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 September 2012 17:17, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Yes, but you are a lot less likely to know about it if you BUG out.  =
The
> user will be left with no other choice than hitting reset or poweroff=
=2E
> What's the point of that?
>
> If your driver crashes but the machine is left running, then the user
> may forward the Oops to you.  That's much more useful.

Good point, I hadn't considered that.

So for user reportability am I better off to use WARN_ON in this case,
or simply remove the check and let the null pointer dereference
happen?

-Steve
