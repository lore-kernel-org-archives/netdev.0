From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] net: ppp: use {get,put}_unaligned_be{16,32}
Date: Sat, 8 Jan 2011 08:43:01 +0800
Message-ID: <AANLkTim=1GCah0qp8HJK31LWXPb5vAZYp+d2BTQM+Q+B@mail.gmail.com>
References: <1294357056-25889-1-git-send-email-xiaosuo@gmail.com> <20110107030145.GA8021@brick.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Harvey Harrison <harvey.harrison@gmail.com>,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20110107030145.GA8021@brick.ozlabs.ibm.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 7, 2011 at 11:01 AM, Paul Mackerras <paulus@samba.org> wrot=
e:
> On Fri, Jan 07, 2011 at 07:37:36AM +0800, Changli Gao wrote:
>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> This patch description is inadequate. =A0It should tell us why you ar=
e
> making this change. =A0Does it result in smaller and/or faster code, =
and
> if so by how much on what sort of machine? =A0Do you think it makes t=
he
> code clearer? =A0(I don't.) =A0Or is there some other motivation for =
this?
>

Good designed APIs always make code clearer, smaller and faster. It is
obvious enough I think.

The names of the functions imply the endianness, like comments. On
some MIPS architectures which support unaligned load and store
instructions, the APIs result in smaller and faster code.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
