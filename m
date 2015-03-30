From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 5/7] ssb: Use bool function return values of true/false not 1/0
Date: Mon, 30 Mar 2015 21:39:13 +0300
Message-ID: <87twx21ga6.fsf@kamboji.qca.qualcomm.com>
References: <cover.1427736972.git.joe@perches.com>
	<57da8293b865fb2d119e29073aec54323fc10000.1427736972.git.joe@perches.com>
	<20150330194901.5293fbe2@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael =?utf-8?Q?B=C3=BCsch?= <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150330194901.5293fbe2@wiggum> ("Michael =?utf-8?Q?B=C3=BCs?=
 =?utf-8?Q?ch=22's?= message of
	"Mon, 30 Mar 2015 19:49:01 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael B=C3=BCsch <m@bues.ch> writes:

> On Mon, 30 Mar 2015 10:43:21 -0700
> Joe Perches <joe@perches.com> wrote:
>
>> Use the normal return values for bool functions
>>=20
>> Signed-off-by: Joe Perches <joe@perches.com>
>> ---
>>  drivers/ssb/driver_gige.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/drivers/ssb/driver_gige.c b/drivers/ssb/driver_gige.c
>> index e973405..ebee6b0 100644
>> --- a/drivers/ssb/driver_gige.c
>> +++ b/drivers/ssb/driver_gige.c
>> @@ -242,7 +242,7 @@ static int ssb_gige_probe(struct ssb_device *sde=
v,
>>  bool pdev_is_ssb_gige_core(struct pci_dev *pdev)
>>  {
>>  	if (!pdev->resource[0].name)
>> -		return 0;
>> +		return false;
>>  	return (strcmp(pdev->resource[0].name, SSB_GIGE_MEM_RES_NAME) =3D=3D=
 0);
>>  }
>>  EXPORT_SYMBOL(pdev_is_ssb_gige_core);
>
> Looks good.
>
> Signed-off-by: Michael Buesch <m@bues.ch>
>
> Kalle, can you take this one, please?

Sure, I'll apply it in the next few days.

--=20
Kalle Valo
