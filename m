From: Stephan Mueller <smueller@chronox.de>
Subject: Re: linux-next: build warnings after merge of the crypto tree
Date: Tue, 10 Mar 2015 08:02:35 +0100
Message-ID: <1658340.bSp4ddJdxm@tauon>
References: <20150310164417.540c18a4@canb.auug.org.au> <20150310060328.GA14997@gondor.apana.org.au> <20150310174454.7a92a3bd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150310174454.7a92a3bd@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 10. M=E4rz 2015, 17:44:54 schrieb Stephen Rothwell:

Hi Stephen,

>Hi Herbert,
>
>On Tue, 10 Mar 2015 17:03:28 +1100 Herbert Xu=20
<herbert@gondor.apana.org.au> wrote:
>> On Tue, Mar 10, 2015 at 04:44:17PM +1100, Stephen Rothwell wrote:
>> > After merging the crypto tree, today's (and the past few days)
>> > linux-next build (powerpc allyesconfig) produced these warnings:
>> >=20
>> > crypto/algif_aead.c:561:2: warning: initialization from
>> > incompatible pointer type> >=20
>> >   .sendmsg =3D aead_sendmsg,
>> >   ^
>> >=20
>> > crypto/algif_aead.c:561:2: warning: (near initialization for
>> > 'algif_aead_ops.sendmsg') crypto/algif_aead.c:563:2: warning:
>> > initialization from incompatible pointer type> >=20
>> >   .recvmsg =3D aead_recvmsg,
>> >   ^
>> >=20
>> > crypto/algif_aead.c:563:2: warning: (near initialization for
>> > 'algif_aead_ops.recvmsg')
>> >=20
>> > Introduced by commit 400c40cf78da ("crypto: algif - add AEAD
>> > support").>=20
>> This is a bit of a bummer.  What happened is that net-next has
>> killed the kiocb argument to sendmsg/recvmsg.  However, this
>> change is obviously not part of the crypto tree and algif_aead
>> only exists in the crypto tree.
>>=20
>> So Stephen could you fix this by hand until one of them is merged
>> upstream (just kill the first argument in aead_sendmsg/aead_recvmsg)=
?
>
>No worries, I will put a merge fix patch in from tomorrow (and send yo=
u
>a copy just in case).

Thank you. Let me know if I should help.


Ciao
Stephan
