From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: Re: problem with flowi structure
Date: Fri, 17 Sep 2010 20:25:23 +0200
Message-ID: <AANLkTi=hXc_ijNgxW+Q6jkRP_T1zjyy2mvKAdTSgeh7w@mail.gmail.com>
References: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com>
 <1284650768.3352.37.camel@edumazet-laptop> <AANLkTimo1AeBS3rpQj0KtZL15Ct-DGTQMBUsL8hrVNOL@mail.gmail.com>
 <1284652453.3352.38.camel@edumazet-laptop> <AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
 <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com>
 <AANLkTimpnqNSE21u=2qjb5VGJrn_3_--Bqp4veCNXMPE@mail.gmail.com>
 <1284714533.3391.53.camel@edumazet-laptop> <AANLkTi=r__RA=5UfNnhsKizDF6OFVYXcSe9KOPx1zW0u@mail.gmail.com>
 <1284741295.3391.100.camel@edumazet-laptop> <AANLkTi=t2=jqu3XCC-3LK7x1_icke168Bqt-kmds6eOt@mail.gmail.com>
 <1284745887.2235.7.camel@edumazet-laptop> <AANLkTinx_18cVq52tmC0-g0qLYXJ5c_u9aad_rz_p2ND@mail.gmail.com>
 <1284746879.2235.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: AIJAZ BAIG <aijazbaig1@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1284746879.2235.9.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 17, 2010 at 8:07 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 17 septembre 2010 =E0 20:01 +0200, Nicola Padovano a =E9c=
rit :
>> > if you say now :
>> >
>> > Send a packet to google, please, I dont care of what source addres=
s you
>> > chose, but I am interested to receive an answer, of course. (appli=
cation
>> > does not use bind() system call, only a send())
>>
>> why an application that wants to send a packet to google would send =
it
>> with a different source ip of the host in which it resides?
>> ie. an application is on a machine which ip is: 192.168.0.2 and the
>> machine has only one ip address...
>>
>
> I dont understand the question or the problem.
>
> If you look closer, you can see your machine has at least two address=
es.

ok, let's try in this way.

the code is this:

[CODE]
if (hooknumber =3D=3D NF_INET_LOCAL_IN) fl.nl_u.ip4_u.saddr =3D niph->s=
addr;
  //niph is the pointer to ip header of the packet to send
if (hooknumber =3D=3D NF_INET_FORWARD) fl.nl_u.ip4_u.saddr =3D 0;
[/CODE]

so, i don't understand why saddr =3D 0 when the hooknumber is NF_INET_F=
ORWARD....

this is the real problem.

--=20
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
