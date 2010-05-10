From: Bijay Singh <Bijay.Singh@guavus.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Mon, 10 May 2010 17:27:28 +0000
Message-ID: <884B3D18-4181-4D98-A8FD-8660CE658C0B@guavus.com>
References: <1273085598.2367.233.camel@edumazet-laptop>
 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
 <1273147586.2357.63.camel@edumazet-laptop>
 <20100506.220443.135536330.davem@davemloft.net>
 <1273210329.2222.42.camel@edumazet-laptop> <20100507101451.1b4286b7@nehalam>
 <1273252893.2261.84.camel@edumazet-laptop> <20100507103639.4f1a51fa@nehalam>
 <1273268446.2325.53.camel@edumazet-laptop>
 <D1C2B1EC-ABE8-4D87-9227-6D0F1C1C8B77@guavus.com>
 <1273504693.2221.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	"<bhaskie@gmail.com>" <bhaskie@gmail.com>,
	"<bhutchings@solarflare.com>" <bhutchings@solarflare.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [204.232.241.167] ([204.232.241.167]:56916 "EHLO mx1.guavus.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753778Ab0EJR1c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 13:27:32 -0400
In-Reply-To: <1273504693.2221.17.camel@edumazet-laptop>
Content-Language: en-US
Content-ID: <51878d71-deeb-4cea-aa77-afaa313f34c8>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Didn't intend to mix  the issues. It was a hack intended to calm the ne=
rves. I am going to apply the proper patches asap.

About the latest problem of MD5 not working with MTU set to 4470. I not=
iced this when i needed to change the MTU for some other  purpose.=20

Since it was a production box, i have to first set up my box with the r=
ight NIC card to reproduce this and try debugging it. In the meantime a=
ny ques will  help.

Thanks,
Bijay
=20
On 10-May-2010, at 8:48 PM, Eric Dumazet wrote:

> Le lundi 10 mai 2010 =E0 14:55 +0000, Bijay Singh a =E9crit :
>> Hi,
>> I had noticed the corruption in the context and actually did what is=
 mentioned.
>>=20
>> I allocated the context on the stack and plugged in the md5.c functi=
ons. I was able to temporarily solve the problem, all this before I got=
 a response on this thread.
>>=20
>> But now I have seeing another problem, when i change the MTU on the =
interface from 1500 to 4470 none of the message from the peer get thru =
and I get hash failed message. I am wondering if this is another bug ge=
tting hit in this scenario.
>=20
> Thats very fine, but you mix very different problems.
>=20
> Step by step resolution is required, and clean patches too, because
> plugging md5.c functions is not an option for stable series :)
>=20
> Obviously, nobody seriously used TCP-MD5 on linux, but you...
>=20
>=20
>=20

