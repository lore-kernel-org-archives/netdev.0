From: David Vrabel <dvrabel@cantab.net>
Subject: Re: IP1000 gigabit nic driver
Date: Thu, 27 Apr 2006 23:26:07 +0100
Message-ID: <445144FF.4070703@cantab.net>
References: <20060427142939.GA31473@fargo> <20060427185627.GA30871@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rutherford.zen.co.uk ([212.23.3.142]:7315 "EHLO
	rutherford.zen.co.uk") by vger.kernel.org with ESMTP
	id S1751652AbWD0W0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 18:26:12 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060427185627.GA30871@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancois Romieu wrote:
> David G=C3=B3mez <david@pleyades.net> :
> [...]
>> Does anybody in this list know why the IP1000 driver is not
>> included in the kernel ?
>=20
> Afaik the driver has never been submitted for inclusion.
> At least not on netdev@vger.kernel.org (hint, hint).
>=20
> [...]
>> The card in question is:
>>
>> Sundance Technology Inc IC Plus IP1000
>>
>> and the driver can be found in sundance web, sources=20
>=20
> URL please ?
>=20
>> included. I tried to contact the author but my email
>> bounced.
>>
>> There's no LICENSE in the source, just copyrigth
>> sentences in the .c files, so i'm not sure under
>> which license it's distributed :-?.
>=20
> /me goes to http://www.icplus.com.tw/driver-pp-IP1000A.html
>=20
> $ unzip -c IP1000A-Linux-driver-v2.09f.zip | grep MODULE_LICENSE
>     MODULE_LICENSE("GPL");
>=20
> It's a bit bloaty but it does not seem too bad (not mergeable "as
> is" though). Do you volunteer to test random cra^W^W carefully
> engineered code on your computer to help the rework/merging process ?

I finally got around to putting a 2nd NIC in my box that has one of thi=
s=20
chips and was going to start fixing the driver up and preparing it for=20
submission this weekend.  Or I might try rewriting from scratch based o=
n=20
the datasheet depending on how horrific the code looks on closer inspec=
tion.

Not got a whole lot of time to do this so no timescale for completion..=
=2E

David Vrabel

