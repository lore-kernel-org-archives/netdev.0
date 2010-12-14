From: =?KOI8-R?B?5M3J1NLJyiDiwczBy8nO?= <dmitriy.balakin@nicneiron.ru>
Subject: Re: Fw: [Bug 24842] New: Compatibility issue with uggly Windows
 RFC1323 implementation.
Date: Tue, 14 Dec 2010 03:35:23 +0300
Message-ID: <AANLkTikbNK-VCPwFcSa5CTyyUoME+xsmxuaQ9EauKs2Z@mail.gmail.com>
References: <20101213085913.374c1072@nehalam> <1292260479.2759.69.camel@edumazet-laptop>
 <AANLkTikTgbKSNYHthic8P3bi9+ewN8fEBknnSK=tdTgU@mail.gmail.com> <1292279462.2679.146.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:46235 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab0LNAgJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 19:36:09 -0500
Received: by yxt3 with SMTP id 3so40333yxt.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 16:36:08 -0800 (PST)
In-Reply-To: <1292279462.2679.146.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

14 =D0=B4=D0=B5=D0=BA=D0=B0=D0=B1=D1=80=D1=8F 2010=C2=A0=D0=B3. 1:31 =D0=
=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=BE=D0=B2=D0=B0=D1=82=D0=B5=D0=BB=D1=8C E=
ric Dumazet
<eric.dumazet@gmail.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB:
> Le lundi 13 d=C3=A9cembre 2010 =C3=A0 23:44 +0300, =D0=94=D0=BC=D0=B8=
=D1=82=D1=80=D0=B8=D0=B9 =D0=91=D0=B0=D0=BB=D0=B0=D0=BA=D0=B8=D0=BD a =C3=
=A9crit :
>> 2010/12/13 Eric Dumazet <eric.dumazet@gmail.com>:
>> > Le lundi 13 d=C3=A9cembre 2010 =C3=A0 08:59 -0800, Stephen Hemming=
er a =C3=A9crit :
>> >>
>> >> Begin forwarded message:
>> >>
>> >> Date: Mon, 13 Dec 2010 14:29:58 GMT
>> >> From: bugzilla-daemon@bugzilla.kernel.org
>> >> To: shemminger@linux-foundation.org
>> >> Subject: [Bug 24842] New: Compatibility issue with uggly Windows =
RFC1323 implementation.
>> >>
>> >>
>> >> https://bugzilla.kernel.org/show_bug.cgi?id=3D24842
>> >>
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Summary: Compatibility i=
ssue with uggly Windows RFC1323
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 implementation.
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Product: Networking
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Version: 2.5
>> >> =C2=A0 =C2=A0 Kernel Version: All
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Platform: All
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 OS/Version: Linux
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Tree: Mainline
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Status: NEW
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Severity: normal
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Priority: P1
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Component: IPV4
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 AssignedTo: shemminger@linux-foundati=
on.org
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ReportedBy: dmitriy.balakin@nicneiron=
=2Eru
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Regression: No
>> >>
>> >>
>> >> Created an attachment (id=3D40012)
>> >> =C2=A0--> (https://bugzilla.kernel.org/attachment.cgi?id=3D40012)
>> >> Patch
>> >>
>> >> First, sorry for my bad english.
>> >>
>> >> The issue is that Linux-based OS sometimes can't make an tcp conn=
ection to some
>> >> Windows servers with switched on buggy implementation of rfc1323,=
 that
>> >> described on this forum:
>> >> http://www.network-builders.com/windows-tcp-timestamp-not-complia=
nt-rfc-1323-a-t80898.html.
>> >>
>> >> Because some Windows hosts implementation of rfc1323 bases on ran=
domly
>> >> generated TSval and sent first value of TSval as 0, the differenc=
e of recent
>> >> and new TSval sometimes has been affected by a sign magic issue a=
nd the PAWS
>> >> mechanism has been triggered. Anyway, the rfc1323 has discribes t=
he condition
>> >> of PAWS as "0 < (t - s) < 2**31", that has been right implementat=
ion in current
>> >> linux kernel, but incompatible with Windows bug.
>> >>
>> >> For example, the one of affected to this issue Windows host is be=
hind
>> >> relay.n-l-e.ru:80
>> >>
>> >> I think that my small patch makes the kernel more compatible with=
 this windows
>> >> bug.
>> >>
>> >> -
>> >
>> > I have no problem connecting my linux client to relay.n-l-e.ru:80
>> >
>> > Could you elaborate please ?
>> >
>> > 18:13:12.444250 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags=
 [S],
>> > seq 665972386, win 5840, options [mss 1460,sackOK,TS val 1746885 e=
cr
>> > 0,nop,wscale 7], length 0
>> > 18:13:12.473912 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags=
 [S.],
>> > seq 190215045, ack 665972387, win 5792, options [mss 1460,sackOK,T=
S val
>> > 730697107 ecr 1746885,nop,wscale 0], length 0
>> > 18:13:12.473976 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags=
 [.],
>> > ack 1, win 46, options [nop,nop,TS val 1746888 ecr 730697107], len=
gth 0
>> > 18:13:14.984153 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags=
 [P.],
>> > seq 1:8, ack 1, win 46, options [nop,nop,TS val 1747139 ecr 730697=
107],
>> > length 7
>> > 18:13:15.013901 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags=
 [.],
>> > ack 8, win 5792, options [nop,nop,TS val 730697360 ecr 1747139], l=
ength
>> > 0
>> > 18:13:15.377879 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags=
 [P.],
>> > seq 8:10, ack 1, win 46, options [nop,nop,TS val 1747178 ecr 73069=
7360],
>> > length 2
>> > 18:13:15.403900 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags=
 [.],
>> > ack 10, win 5792, options [nop,nop,TS val 730697399 ecr 1747178], =
length
>> > 0
>> > 18:13:15.461384 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags=
 [P.],
>> > seq 1:159, ack 10, win 5792, options [nop,nop,TS val 730697405 ecr
>> > 1747178], length 158
>> > 18:13:15.461429 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags=
 [.],
>> > ack 159, win 54, options [nop,nop,TS val 1747186 ecr 730697405], l=
ength
>> > 0
>> > 18:13:15.461448 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags=
 [F.],
>> > seq 159, ack 10, win 5792, options [nop,nop,TS val 730697405 ecr
>> > 1747178], length 0
>> > 18:13:15.461607 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags=
 [F.],
>> > seq 10, ack 160, win 54, options [nop,nop,TS val 1747186 ecr 73069=
7405],
>> > length 0
>> > 18:13:15.533846 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags=
 [.],
>> > ack 11, win 5792, options [nop,nop,TS val 730697412 ecr 1747186], =
length
>> > 0
>> >
>> >
>> >
>>
>> Problems occur only when the remote side sets the TC val > 214748364=
7,
>> ie when there is a sign:
>>
>
> You mean a windows machine with a big uptime ?
> That must be quite rare indeed ;)
>
> Anyway, we can not test values like suggested patch, or risk a proble=
m
> when wrap around occurs...
>
> However, testing the special ts_recent=3D0 case would be possible (we
> already did a change to accept a windows initiated connect to a linux
> server and still activate tcp timestamps)
>
> (commit fc1ad92dfc4e363a055 tcp: allow timestamps even if SYN packet =
has
> tsval=3D0)
>
> Something like following patch ?
>
> Thanks
>
>
> [PATCH net-next-2.6] tcp: relax tcp_paws_check()
>
> Some windows versions have wrong RFC1323 implementations, with SYN an=
d
> SYNACKS messages containing zero tcp timestamps.
>
> We relaxed in commit fc1ad92dfc4e363 the passive connection case
> (Windows connects to a linux machine), but the reverse case (linux
> connects to a Windows machine) has an analogue problem when tsvals fr=
om
> windows machine are 'negative' (high order bit set) : PAWS triggers a=
nd
> we drops incoming messages.
>
> Fix this by making zero ts_recent value special, allowing frame to be
> processed.
>
> Based on a report and initial patch from Dmitiy Balakin
>
> Bugzilla reference : https://bugzilla.kernel.org/show_bug.cgi?id=3D24=
842
>
> Reported-by: dmitriy.balakin@nicneiron.ru
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =C2=A0include/net/tcp.h | =C2=A0 =C2=A08 +++++++-
> =C2=A01 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 3f227ba..2ab6c9c 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1038,7 +1038,13 @@ static inline int tcp_paws_check(const struct =
tcp_options_received *rx_opt,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(get_seconds() >=3D rx_opt->ts=
_recent_stamp + TCP_PAWS_24DAYS))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> -
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Some OSes send SYN and SYNACK messages=
 with tsval=3D0 tsecr=3D0,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* then following tcp messages have valid=
 values. Ignore 0 value,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* or else 'negative' tsval might forbid =
us to accept their packets.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (!rx_opt->ts_recent)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
>
>
>

In Windows uptime should be about 7 years old to sign is appear in a
TS value, it really should be quite rare. But there is such a systems,
where the TS value has nothing to do with uptime and randomly
generated for each TCP connection, such as the one referred to
earlier.

Yes, you're right, my patch breaks the PAWS. Your patch is the right wa=
y.

Thanks!
