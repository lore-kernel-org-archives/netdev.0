From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 14:32:36 +0200
Message-ID: <4BADFAE4.5040906@iki.fi>
References: <4BADDDB7.4010005@iki.fi> <20100327114059.GA3432@electric-eye.fr.zoreil.com> <4BADF01E.9090906@iki.fi> <20100327120358.GA5114@electric-eye.fr.zoreil.com> <4BADF738.2060600@iki.fi> <20100327122642.GA5165@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois_Romieu?= <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:36365 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931Ab0C0Mck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 08:32:40 -0400
Received: by ewy20 with SMTP id 20so242744ewy.1
        for <netdev@vger.kernel.org>; Sat, 27 Mar 2010 05:32:38 -0700 (PDT)
In-Reply-To: <20100327122642.GA5165@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ran=E7ois Romieu wrote:
> Timo Ter=E4s <timo.teras@iki.fi> :
> [...]
>> It seems that adding single printk between writing MAC0 and MAC4 fix=
es it.
>> I guess it needs a bit of delay between the writes or something.
>=20
> Can you test with a single RTL_R32 after each MACx write ?

Adding reading back of the written value fixes it too. Though, disassem=
bly
says that it added an extra instructions also (needs to load the 'high'=
 from
stack before writing it) so the added delay is probably slightly more t=
han
just the io read.

