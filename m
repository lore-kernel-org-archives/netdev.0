From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/isdn: break out of the loop after call isdn_tty_send_msg
Date: Fri, 29 Mar 2013 09:56:30 +0800
Message-ID: <5154F4CE.2010200@asianux.com>
References: <512DD2B3.2070404@asianux.com> <512DD94C.2020008@suse.cz> <512EC79C.3010700@asianux.com> <512F296E.1050303@suse.cz> <51428134.50601@asianux.com> <51494336.7070202@asianux.com> <514FC42A.3030807@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Slaby <jslaby@suse.cz>, David Miller <davem@davemloft.net>,
	isdn@linux-pingi.de, Greg KH <gregkh@linuxfoundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:33882 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996Ab3C2CXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 22:23:24 -0400
In-Reply-To: <514FC42A.3030807@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David Miller:

  could you help to check this patch whether is OK ?

  originally, it is my fault:
    not think of the mail addresses, after get them from ./scripts/get_=
maintainers.pl
    (I should fully use the tools, but should not depend on the tools)

  thanks.


On 2013=E5=B9=B403=E6=9C=8825=E6=97=A5 11:27, Chen Gang wrote:
> Hello Jiri Kosina:
>=20
>   could you help to check this patch whether is OK ?
>=20
>   thanks.
>=20
>   :-)
>=20
> gchen.
>=20
>=20
> On 2013=E5=B9=B403=E6=9C=8820=E6=97=A5 13:03, Chen Gang wrote:
>> Hello Maintainers:
>>
>>   did I send incorrect mail address ?
>>     ./scripts/get_maintainers.pl leads to cc netdev, but exclude Dav=
id Miller.
>>     is it a bug of ./scripts/get_maintainers.pl ?
>>       (this time, I include him in this mail address).
>>
>>   welcome any members to providing suggestions or completions.
>>
>>   thanks.
>>
>> gchen.
>>
>> On 2013=E5=B9=B403=E6=9C=8815=E6=97=A5 10:02, Chen Gang wrote:
>>> Hello Maintainers:
>>>
>>>   is it qualified to be applied ?
>>>
>>>   thanks.
>>>
>>>
>>> =E4=BA=8E 2013=E5=B9=B402=E6=9C=8828=E6=97=A5 17:54, Jiri Slaby =E5=
=86=99=E9=81=93:
>>>> On 02/28/2013 03:57 AM, Chen Gang wrote:
>>>>>
>>>>>   need break out of the loop after call isdn_tty_send_msg.
>>>>>     isdn_tty_send_msg is intended to eat the rest of the string.
>>>>>     so need not scan again the string which appended "+M...".
>>>>
>>>> Yes, looks good.
>>>>
>>>>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>>>>> ---
>>>>>  drivers/isdn/i4l/isdn_tty.c |    4 +++-
>>>>>  1 files changed, 3 insertions(+), 1 deletions(-)
>>>>>
>>>>> diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_=
tty.c
>>>>> index d8a7d83..8ac7b33 100644
>>>>> --- a/drivers/isdn/i4l/isdn_tty.c
>>>>> +++ b/drivers/isdn/i4l/isdn_tty.c
>>>>> @@ -3587,7 +3587,7 @@ isdn_tty_parse_at(modem_info *info)
>>>>>  			case 'M':	/* MESSAGE */
>>>>>  				p++;
>>>>>  				isdn_tty_send_msg(info, m, p);
>>>>> -				break;
>>>>> +				goto tail;
>>>>>  			default:
>>>>>  				PARSE_ERROR;
>>>>>  			}
>>>>> @@ -3601,6 +3601,8 @@ isdn_tty_parse_at(modem_info *info)
>>>>>  			PARSE_ERROR;
>>>>>  		}
>>>>>  	}
>>>>> +
>>>>> +tail:
>>>>>  #ifdef CONFIG_ISDN_AUDIO
>>>>>  	if (!info->vonline)
>>>>>  #endif
>>>>>
>>>>
>>>>
>>>
>>>
>>
>>
>=20
>=20


--=20
Chen Gang

Asianux Corporation
