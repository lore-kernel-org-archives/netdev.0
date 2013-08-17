From: Haojian Zhuang <haojian.zhuang@gmail.com>
Subject: Re: [PATCH RESEND] can: mcp251x: Replace power callbacks with
 regulator API
Date: Sat, 17 Aug 2013 12:37:59 +0800
Message-ID: <CAN1soZz68ymkj4x5bWTP-6Qc7zVuVotLoT8nYLrdTd3DQHyFbQ@mail.gmail.com>
References: <1375963227-6468-1-git-send-email-shc_work@mail.ru>
	<52049C44.6030902@pengutronix.de>
	<520EDDA8.6050309@gmail.com>
	<20130817083014.a01144051b158c34ec7dd9d9@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	Russell King <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:65377 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964Ab3HQEiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 00:38:01 -0400
In-Reply-To: <20130817083014.a01144051b158c34ec7dd9d9@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 17, 2013 at 12:30 PM, Alexander Shiyan <shc_work@mail.ru> wrote:
> On Sat, 17 Aug 2013 10:19:20 +0800
> Haojian Zhuang <haojian.zhuang@gmail.com> wrote:
>
>> On 08/09/2013 03:37 PM, Marc Kleine-Budde wrote:
>> > On 08/08/2013 02:00 PM, Alexander Shiyan wrote:
>> >> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
>> >> ---
>> >>   arch/arm/mach-pxa/icontrol.c         |  3 --
>> >>   arch/arm/mach-pxa/zeus.c             | 46 ++++++++++----------
>> >
>> > What's pxa's status of DT conversion? Do you (still) accept patches to
>> > board files?
>> >
>> > Marc
>> >
>>
>> Since DT conversion isn't finished, I still accept the board files.
>> But this patch should be split into two parts. One is for pxa, and the
>> other one is for net.
>
> Patch cannot be splitted because this can create hole which break git-bisect.
>
> In any case, I want to create a v2 with a more detailed description, and I
> have a supplementary question for the CAN subsystem maintainers.
> "Transciever power" is not used by any of the boards, can we remove it
> completely? This will greatly simplify driver.
> Thanks.
>
> --
> Alexander Shiyan <shc_work@mail.ru>

If you want to make the patch go through pxa tree, you need to get the Ack
from CAN maintainer.

Regards
Haojian
