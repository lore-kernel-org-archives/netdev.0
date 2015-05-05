From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2] adm8211: fix checkpatch error for trailing statements on next line
Date: Tue, 05 May 2015 08:30:51 +0300
Message-ID: <87k2wnvbec.fsf@kamboji.qca.qualcomm.com>
References: <20150503104231.GA3607@bytefire-computer>
	<87lhh4wm3n.fsf@kamboji.qca.qualcomm.com>
	<20150505051827.GA2463@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Okash Khawaja <okash.khawaja@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48905 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568AbbEEFa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 01:30:58 -0400
In-Reply-To: <20150505051827.GA2463@bytefire-computer> (Okash Khawaja's
	message of "Tue, 5 May 2015 06:19:38 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Okash Khawaja <okash.khawaja@gmail.com> writes:

> On Mon, May 04, 2015 at 03:42:04PM +0300, Kalle Valo wrote:
>> Okash Khawaja <okash.khawaja@gmail.com> writes:
>> 
>> > This patch fixes the checkpatch.pl error:
>> >
>> > ERROR: trailing statements should be on next line
>> >
>> > More specifically, the fix has been applied to the four occurances of the error listed below.
>> >
>> > ERROR: trailing statements should be on next line
>> > #1101: FILE: drivers/net/wireless/adm8211.c:1101:
>> > +               case  0x8: reg |= (0x1 << 14);
>> >
>> > ERROR: trailing statements should be on next line
>> > #1103: FILE: drivers/net/wireless/adm8211.c:1103:
>> > +               case 0x16: reg |= (0x2 << 14);
>> >
>> > ERROR: trailing statements should be on next line
>> > #1105: FILE: drivers/net/wireless/adm8211.c:1105:
>> > +               case 0x32: reg |= (0x3 << 14);
>> >
>> > ERROR: trailing statements should be on next line
>> > #1107: FILE: drivers/net/wireless/adm8211.c:1107:
>> > +                 default: reg |= (0x0 << 14);
>> >
>> > Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>
>> > ---
>> >  drivers/net/wireless/adm8211.c | 20 ++++++++++++--------
>> >  1 file changed, 12 insertions(+), 8 deletions(-)
>> 
>> The patch has incorrectly "staging:" prefix in the title, please fix
>> that. "adm8211:" is enough, you don't need anything for drivers in
>> drivers/net/wireless.
>> 
>> -- 
>> Kalle Valo
>
> Thanks Kalle for clarifying. I have removed "staging:" prefix and pasted the patch below.
>
> Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>

I cannot apply the mail directly as you added the old discussion to the
commit log. Please just resend the whole patch with clean commit log.

-- 
Kalle Valo
