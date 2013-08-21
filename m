From: Haojian Zhuang <haojian.zhuang@gmail.com>
Subject: Re: [PATCH RESEND] can: mcp251x: Replace power callbacks with
 regulator API
Date: Wed, 21 Aug 2013 08:46:00 +0800
Message-ID: <CAN1soZyM8x4cWqqjk4az37Njvgez0teTnKuGa2ZQ4od-3sm6MQ@mail.gmail.com>
References: <1375963227-6468-1-git-send-email-shc_work@mail.ru>
	<52049C44.6030902@pengutronix.de>
	<520EDDA8.6050309@gmail.com>
	<20130817083014.a01144051b158c34ec7dd9d9@mail.ru>
	<CAN1soZz68ymkj4x5bWTP-6Qc7zVuVotLoT8nYLrdTd3DQHyFbQ@mail.gmail.com>
	<52132CD7.50100@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Shiyan <shc_work@mail.ru>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	Russell King <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52132CD7.50100@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 20, 2013 at 4:46 PM, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
> On 08/17/2013 06:37 AM, Haojian Zhuang wrote:
>> On Sat, Aug 17, 2013 at 12:30 PM, Alexander Shiyan <shc_work@mail.ru> wrote:
>>> On Sat, 17 Aug 2013 10:19:20 +0800
>>> Haojian Zhuang <haojian.zhuang@gmail.com> wrote:
>>>
>>>> On 08/09/2013 03:37 PM, Marc Kleine-Budde wrote:
>>>>> On 08/08/2013 02:00 PM, Alexander Shiyan wrote:
>>>>>> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
>>>>>> ---
>>>>>>   arch/arm/mach-pxa/icontrol.c         |  3 --
>>>>>>   arch/arm/mach-pxa/zeus.c             | 46 ++++++++++----------
>>>>>
>>>>> What's pxa's status of DT conversion? Do you (still) accept patches to
>>>>> board files?
>>>>>
>>>>> Marc
>>>>>
>>>>
>>>> Since DT conversion isn't finished, I still accept the board files.
>>>> But this patch should be split into two parts. One is for pxa, and the
>>>> other one is for net.
>>>
>>> Patch cannot be splitted because this can create hole which break git-bisect.
>>>
>>> In any case, I want to create a v2 with a more detailed description, and I
>>> have a supplementary question for the CAN subsystem maintainers.
>>> "Transciever power" is not used by any of the boards, can we remove it
>>> completely? This will greatly simplify driver.
>>> Thanks.
>>>
>>> --
>>> Alexander Shiyan <shc_work@mail.ru>
>>
>> If you want to make the patch go through pxa tree, you need to get the Ack
>> from CAN maintainer.
>
> The current series consists of 3 patches, only the first one touches
> "arch/arm/mach-pxa", so I'd like the patches to go via linux-can. Can I
> have your Acked-by for the first patch "[PATCH v2 1/3] can: mcp251x:
> Replace power callbacks with regulator AP"
>
> Marc
> --
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
>

Acked-by: Haojian Zhuang <haojian.zhuang@gmail.com>
