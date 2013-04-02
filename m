From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/isdn/divert: beautify code, delete useless 'break'
Date: Tue, 02 Apr 2013 08:44:29 +0800
Message-ID: <515A29ED.7010809@asianux.com>
References: <5158E854.7060902@asianux.com> <515993E1.5010508@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: isdn@linux-pingi.de, Jiri Slaby <jslaby@suse.cz>,
	'Jiri Kosina' <trivial@kernel.org>, tilman@imap.cc,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:33406 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242Ab3DBApK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 20:45:10 -0400
In-Reply-To: <515993E1.5010508@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8801=E6=97=A5 22:04, Sergei Shtylyov wrote:
>=20
>> diff --git a/drivers/isdn/divert/isdn_divert.c
>> b/drivers/isdn/divert/isdn_divert.c
>> index db432e6..76d505e 100644
>> --- a/drivers/isdn/divert/isdn_divert.c
>> +++ b/drivers/isdn/divert/isdn_divert.c
>> @@ -442,7 +442,6 @@ static int isdn_divert_icall(isdn_ctrl *ic)
>>           switch (dv->rule.action) {
>>           case DEFLECT_IGNORE:
>>               return (0);
>> -            break;
>>
>>           case DEFLECT_ALERT:
>>           case DEFLECT_PROCEED:
>> @@ -511,7 +510,6 @@ static int isdn_divert_icall(isdn_ctrl *ic)
>>
>>           default:
>>               return (0); /* ignore call */
>> -            break;
>=20
>    You could have removed stupid () around 0, while at it.

  oh, really, I should do it.

  I will send patch v2 for it

  thanks.

  :-)

--=20
Chen Gang

Asianux Corporation
