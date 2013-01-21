From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net 0/3] cdc_ncm and cdc_mbim fixes for 3.8
Date: Mon, 21 Jan 2013 23:12:24 +0100
Message-ID: <87d2wyb2yf.fsf@nemi.mork.no>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
	<20130121.142242.2240250911008731906.davem@davemloft.net>
	<2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D99@EXDCVYMBSTM006.EQ1STM.local>
	<f47edcc4-cda9-4349-9590-ee8572b139ca@email.android.com>
	<CAL_Kpj2QsUqLLCnME3zNHxJpcrJZufN1ZMT=vRsr_gzs70gvpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey ORISHKO <alexey.orishko@stericsson.com>,
	David Miller <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"gsuarez\@smithmicro.com" <gsuarez@smithmicro.com>,
	"oneukum\@suse.de" <oneukum@suse.de>
To: Alexey Orishko <alexey.orishko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44478 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287Ab3AUWNS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 17:13:18 -0500
In-Reply-To: <CAL_Kpj2QsUqLLCnME3zNHxJpcrJZufN1ZMT=vRsr_gzs70gvpQ@mail.gmail.com>
	(Alexey Orishko's message of "Mon, 21 Jan 2013 21:34:11 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Orishko <alexey.orishko@gmail.com> writes:
> On Mon, Jan 21, 2013 at 9:16 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrot=
e:
>> Alexey ORISHKO <alexey.orishko@stericsson.com> wrote:
>>
>>
>> There are still a couple of questions I am wondering about
>> though. The most important one: what is Windows 8 doing different
>> from us? Does anyone know? I do not have a Windows 8 system myself
>> and I wouldn't know how to snoop on it either.
>>
>
> Are you talking about bulk data? They have their own bugs :-) looks
> like can't handle divisor/remainder in NTB right.

Yes, I am talking about bulk data.  Why don't they hit the ZLP issue?
Don't they zero-pad the NTB like we do?

> If you want, I can send you Ellisys log.

Yes, please.  That would be very nice to have.


Bj=C3=B8rn
