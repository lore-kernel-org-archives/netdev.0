From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 14:16:56 +0200
Message-ID: <4BADF738.2060600@iki.fi>
References: <4BADDDB7.4010005@iki.fi> <20100327114059.GA3432@electric-eye.fr.zoreil.com> <4BADF01E.9090906@iki.fi> <20100327120358.GA5114@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois_Romieu?= <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:60374 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912Ab0C0MRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 08:17:00 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1024111eyd.19
        for <netdev@vger.kernel.org>; Sat, 27 Mar 2010 05:16:58 -0700 (PDT)
In-Reply-To: <20100327120358.GA5114@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ran=E7ois Romieu wrote:
> Timo Ter=E4s <timo.teras@iki.fi> :
> [...]
>> I don't think this would do anything. The high part is recorded corr=
ectly always.
>> It's the 'low' part that gets discarded. I can do similar test if wr=
iting it
>> more times will help. Will post results soon.
>=20
> You may check whether writing MAC4 before MAC0 makes a difference
> or not as well.

It seems that adding single printk between writing MAC0 and MAC4 fixes =
it.
I guess it needs a bit of delay between the writes or something.

