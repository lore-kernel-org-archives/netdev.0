From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: Finding a hidden bound TCP socket
Date: Thu, 24 Nov 2011 22:31:55 +0100
Message-ID: <CAFLxGvzAV9ODxo6Bs=ow1J0JRwHYNFmkBqrmN33D7Ci=YvNKNg@mail.gmail.com>
References: <CALmbKGV0g2nfNAghF5dGrt=TCyrms6RznOL8jSkg+gkgyfekLg@mail.gmail.com>
	<CAFLxGvynabpEcX2RwiLxatjOEzizj95jAVY6E4D9ymDpn8s9UA@mail.gmail.com>
	<CALmbKGVUuZs+wigpkr0WPfn2pYP=tQh5-MsYWeRxbug=HskVQQ@mail.gmail.com>
	<20111123.160143.58902472755124590.davem@davemloft.net>
	<4ECD67C7.3010702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, gdfuego@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ECD67C7.3010702@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2011 at 10:38 PM, Rick Jones <rick.jones2@hp.com> wrote=
:
> On 11/23/2011 01:01 PM, David Miller wrote:
>>
>> From: "G. D. Fuego"<gdfuego@gmail.com>
>> Date: Wed, 23 Nov 2011 15:27:33 -0500
>>
>>> Any comments? =A0The behavior seems broken. =A0At the very least it=
s very
>>> inconsistent with other Unixes.
>>
>> Until the socket has a full final tuple it is bound to, there is no
>> reason to list it.
>>
>> No UNIX lists a socket which is partially bound and hasn't either
>> performed a listen() or a connect().
>
> Well.... =A0I took the .c file mentioned previously, and compiled it =
on a
> Solaris 10 8/11 instance. =A0The 25-odd sockets it created *were* lis=
ted in
> the output of netstat -an -- local address as *.<portnum> remote addr=
ess as
> *.* and a state of "BOUND."
>
> A FreeBSD =A0(rev 8 IIRC) netstat -an seems to display them in a stat=
e of
> "CLOSED." =A0I didn't check HP-UX 11i v3 or AIX 6.
>

IRIX (6.5) shows them as "CLOSED".

--=20
Thanks,
//richard
