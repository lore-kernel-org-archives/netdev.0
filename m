From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 1/5] bcma: convert suspend/resume to pm_ops
Date: Fri, 13 Jan 2012 11:01:16 +0100
Message-ID: <CACna6rwM3rs2q7sQLniv+5tcjLkyTYfZzN1XEPwbNt36_kgLtw@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
	<1326440480-26271-1-git-send-email-zajec5@gmail.com>
	<alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
	<alpine.LNX.2.00.1201122359400.5860@air.linux-foundation.org>
	<4F10004B.5010309@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:50890 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab2AMKBR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 05:01:17 -0500
Received: by werb13 with SMTP id b13so235417wer.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 02:01:16 -0800 (PST)
In-Reply-To: <4F10004B.5010309@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 13 stycznia 2012 10:58 u=C5=BCytkownik Arend van Spriel
<arend@broadcom.com> napisa=C5=82:
> On 01/13/2012 09:00 AM, Linus Torvalds wrote:
>>
>> From: Linus Torvalds <torvalds@linux-foundation.org>
>> Date: Thu, 12 Jan 2012 22:47:01 -0800
>>
>> .. and avoid doing th eunnecessary PCI operations - the PCI layer wi=
ll do them for us.
>>
>> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>> ---
>> =C2=A0drivers/bcma/host_pci.c | =C2=A0 38 +++++++++++++-------------=
------------
>> =C2=A01 files changed, 13 insertions(+), 25 deletions(-)
>>
>> diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
>> index 443b83a2fd7a..3aee641c9b7b 100644
>> --- a/drivers/bcma/host_pci.c
>> +++ b/drivers/bcma/host_pci.c
>> @@ -235,38 +235,27 @@ static void bcma_host_pci_remove(struct pci_de=
v *dev)
>> =C2=A0}
>>
>> =C2=A0#ifdef CONFIG_PM
>> -static int bcma_host_pci_suspend(struct pci_dev *dev, pm_message_t =
state)
>> +static int bcma_suspend(struct device *dev)
>
> All functions in host_pci.c start with bcma_host_pci_ prefix. Can we
> stick to that convention?

/me agrees
Would be nice

--=20
Rafa=C5=82
