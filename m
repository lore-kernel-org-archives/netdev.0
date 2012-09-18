From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH] asix: Support DLink DUB-E100 H/W Ver C1
Date: Tue, 18 Sep 2012 10:21:17 +0200
Message-ID: <CABkLObq3jQG_KMRrNpYGsseJrCYQ08cJfQFD5fpTmYDyDMGROA@mail.gmail.com>
References: <1347909800-3056-1-git-send-email-sgh@sgh.dk>
	<CABkLObpU3P84AHTBG1hkrHt_HdaPzdTiRU1ACnJv=Qhb+wYPbQ@mail.gmail.com>
	<1377162.WNQkapDPaD@koontz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: =?UTF-8?Q?S=C3=B8ren_Holm?= <sgh@sgh.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37258 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab2IRIVT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 04:21:19 -0400
In-Reply-To: <1377162.WNQkapDPaD@koontz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 18, 2012 at 9:49 AM, S=C3=B8ren Holm <sgh@sgh.dk> wrote:
> Tirsdag den 18. september 2012 07:41:11 skrev Christian Riesch:
>>
>> This will not apply to recent kernels, drivers/net/usb/asix.c has be=
en
>> split into several files, please make these changes in
>> drivers/net/usb/asix_devices.c.
>
> I'll do that. The previous patch applies to the 3.5.x stable series i=
f it get
> accepted there.

IIRC this is not how it works. Your patch must go into the current
mainline kernel first (via net or net-next) before, then it will be
backported to the stable series.Therefore you must always send patches
that apply to net, or net-next...
Christian
