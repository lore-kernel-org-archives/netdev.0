From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 5/5] smsc95xx: enable power saving mode during system suspend
Date: Wed, 26 Sep 2012 16:58:13 +0100
Message-ID: <CAKh2mn4XLCPfTFySEvtZc56J+WM863JtnsjF2D-RyDJatoyAww@mail.gmail.com>
References: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
	<1348663224-30403-6-git-send-email-steve.glendinning@shawell.net>
	<87y5jw982o.fsf@nemi.mork.no>
	<CAKh2mn5tKowqjbvgWDSz52UF9qY9_ysAb23Pb-M_3wvCG=_R6w@mail.gmail.com>
	<87txuk9453.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:41234 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137Ab2IZP6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 11:58:14 -0400
Received: by obbuo13 with SMTP id uo13so717733obb.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 08:58:13 -0700 (PDT)
In-Reply-To: <87txuk9453.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I hadn't thought that was a situation that could arise, is it?  Would
>> this happen if the USB device was removed during suspend?
>
> No, it should not happen.  But then, why test at all?

I thought it was common practice to add these tests to document an
assumption the developer made that later code relies on?  I had
assumed that the !dev condition should not be possible, hence the
simple BUG test.  If it is possible then I agree - I definitely need
to handle this more gracefully.

In this case, asserting that dev is not NULL will make the code fail
loudly there instead of a few lines down when the netdev_info call
dereferences dev->net.  Either way something bad will happen!

-Steve
