From: Lifeng Sun <lifongsun@gmail.com>
Subject: Re: [PATCH] Applying inappropriate ioctl operation on socket should
 return ENOTTY
Date: Thu, 28 Apr 2011 16:49:31 +0800
Message-ID: <BANLkTikLUssAMHBkPmwKFZja6OMDih_DKQ@mail.gmail.com>
References: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
	<20110427130904.47331a9f@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110427130904.47331a9f@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2011 at 8:09 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wr=
ote:
>> diff --git a/drivers/char/viotape.c b/drivers/char/viotape.c
>> index ad6e64a..a427d40 100644
>> --- a/drivers/char/viotape.c
>> +++ b/drivers/char/viotape.c
>> @@ -529,7 +529,7 @@ static int viotap_ioctl(struct inode *inode, str=
uct file *file,
>>
>> =A0 =A0 =A0 down(&reqSem);
>>
>> - =A0 =A0 ret =3D -EINVAL;
>> + =A0 =A0 ret =3D -ENOTTY;
>
> Again this messes up the returns because code assumes the initial
> default.

> The original code also has bugs too (wrong error off
> copy_*_user() again)

It seems alright.

- Lifeng
