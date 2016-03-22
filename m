From: Wei-Ning Huang <wnhuang@google.com>
Subject: Re: [PATCH] mwifiex: advertise low priority scan feature
Date: Tue, 22 Mar 2016 12:12:29 +0800
Message-ID: <CABicQ-WPZ39iBc_JVUU-vm2NNCq50rhEKXk6KmqQ7s3-uYgbkQ@mail.gmail.com>
References: <1458547622-1632-1-git-send-email-wnhuang@google.com>
	<87d1qogm50.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Daniel Kurtz <djkurtz@chromium.org>,
	Nishant Sarmukadam <nishants@marvell.com>,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34135 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbcCVEMa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 00:12:30 -0400
Received: by mail-oi0-f44.google.com with SMTP id l76so71138815oig.1
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 21:12:29 -0700 (PDT)
In-Reply-To: <87d1qogm50.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kalle,

Thanks for the review. I accidentally removed the s-o-b line from
akarwar in this version.
The original patch can be found at:
https://chromium-review.googlesource.com/#/c/246052/
I've resent a new one.

Wei-Ning

On Mon, Mar 21, 2016 at 6:28 PM, Kalle Valo <kvalo@codeaurora.org> wrot=
e:
> Wei-Ning Huang <wnhuang@chromium.org> writes:
>
>> From: Amitkumar Karwar <akarwar@marvell.com>
>>
>> Low priority scan handling code which delays or aborts scan
>> operation based on Tx traffic is removed recently. The reason
>> is firmware already takes care of it in our new feature scan
>> channel gap. Hence we should advertise low priority scan
>> support to cfg80211.
>>
>> This patch fixes a problem in which OBSS scan request from
>> wpa_supplicant was being rejected by cfg80211.
>>
>> Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
>
> The From line states that this is written by Amitkumar but there's no
> Signed-off-By line from him. I can't take this without that, please
> resend.
>
> (Wei-Ning's s-o-b line is correct, I just need also Amitkumar's line.=
)
>
> --
> Kalle Valo



--=20
Wei-Ning Huang, =E9=BB=83=E5=81=89=E5=AF=A7 | Software Engineer, Google=
 Inc., Taiwan |
wnhuang@google.com | Cell: +886 910-380678
