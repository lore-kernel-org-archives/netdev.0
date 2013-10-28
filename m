From: Peter Schmitt <peter.schmitt82@yahoo.de>
Subject: Re: PROBLEM: GRE forwarding not working with 3.10.x, WCCPv2 and Cisco 7200 Router showing IP0 bad-hlen 4 in tcpdump
Date: Mon, 28 Oct 2013 10:10:11 +0000 (GMT)
Message-ID: <1382955011.46218.YahooMailNeo@web172005.mail.ir2.yahoo.com>
References: <1381912513.57737.YahooMailNeo@web172002.mail.ir2.yahoo.com>	<1381942996.2045.135.camel@edumazet-glaptop.roam.corp.google.com>	<1382007190.35868.YahooMailNeo@web172006.mail.ir2.yahoo.com>	<1382017464.2045.149.camel@edumazet-glaptop.roam.corp.google.com>	<1382096356.63655.YahooMailNeo@web172002.mail.ir2.yahoo.com> <CALnjE+pdvpfCTo=bTtSrY29mxc0yZKMj0XSc2gQVhGjbpByhcA@mail.gmail.com>
Reply-To: Peter Schmitt <peter.schmitt82@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm10-vm1.bullet.mail.ird.yahoo.com ([77.238.189.93]:33842 "HELO
	nm10-vm1.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755714Ab3J1KKN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 06:10:13 -0400
In-Reply-To: <CALnjE+pdvpfCTo=bTtSrY29mxc0yZKMj0XSc2gQVhGjbpByhcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pravin,

I tested this patch and it works fine with 3.10.17! Now I get correct p=
ackets from the GRE-device and can surf again using WCCP.

Thank you very much!

Best regards,
Peter





> On Friday, October 25, 2013 5:25 PM, Pravin Shelar <pshelar@nicira.co=
m> wrote:
> > Hi Peter,
> I think its easy to fix this case, Can you try attached patch?
> If it works I will send formal patch for stable.
>=20
> Thanks,
> Pravin.
>=20
>=20
> On Fri, Oct 18, 2013 at 4:39 AM, Peter Schmitt <peter.schmitt82@yahoo=
=2Ede>=20
> wrote:
>>  Hi,
>>=20
>>=20
>>=20
>>>  On Thursday, October 17, 2013 3:44 PM, Eric Dumazet=20
> <eric.dumazet@gmail.com> wrote:
>>>  > On Thu, 2013-10-17 at 11:53 +0100, Peter Schmitt wrote:
>>>> =A0 Hi,
>>>>=20
>>>>=20
>>>> =A0 >
>>>> =A0 > 3.10 is buggy (for ETH_P_WCCP support I mean), 3.11 has the=20
> probable
>>>> =A0 > fix :
>>>> =A0 >
>>>> =A0 > commit 3d7b46cd20e300bd6989fb1f43d46f1b9645816e
>>>> =A0 > ("ip_tunnel: push generic protocol handling to ip_tunnel
>>>  module.")
>>>> =A0 >
>>>> =A0 > The problem is 3.10 do not pull the extra 4 bytes of WCCP
>>>> =A0 >
>>>> =A0 > This is now properly done in iptunnel_pull_header()
>>>> =A0 >
>>>>=20
>>>> =A0 First of all, many thanks for your help on this.
>>>>=20
>>>> =A0 I tried to apply the fix to the 3.10.16 sources, as I would li=
ke=20
> to
>>>> =A0 stay with the long-term line. Unfortunately it does not apply,=
 as
>>>> =A0 there are a lot of dependencies on other patches.
>>>>=20
>>>> =A0 Do you think there will be a fix for the long-time 3.10 kernel=
=20
> line?
>>>> =A0 Or can you guide me on how to apply this fix to the long-term=20
> kernel?
>>>=20
>>>  3.10 is right in the middle of GRE refactoring, and many bugs are =
in=20
> it.
>>>=20
>>>  It might be very painful to get a complete list of patches to back=
port.
>>=20
>>  thanks again. Yes I saw that there were lots of changes.
>>=20
>>  Do you think there will be a fix for all the 3.10.x stable long ter=
m kernel=20
> users? Many of them might not be able to use some newer kernel easily=
 or will=20
> this be a "won't fix"?
>>=20
>>  Best regards,
>>  Peter
>>=20
>=20
