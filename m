From: David Miller <davem@davemloft.net>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Tue, 28 Feb 2012 14:07:40 -0500 (EST)
Message-ID: <20120228.140740.2121187297378484175.davem@davemloft.net>
References: <4F3BABD3.5070404@msgid.tls.msk.ru>
	<1329311013.2437.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4F4CBCBC.8000703@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: mjt@tls.msk.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030256Ab2B1TJn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 14:09:43 -0500
In-Reply-To: <4F4CBCBC.8000703@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Michael Tokarev <mjt@tls.msk.ru>
Date: Tue, 28 Feb 2012 15:38:36 +0400

> On 15.02.2012 17:03, Eric Dumazet wrote:
>> Le mercredi 15 f=E9vrier 2012 =E0 16:57 +0400, Michael Tokarev a =E9=
crit :
>>=20
>>> 3.0.21 included "net: fix NULL dereferences in check_peer_redir()" =
patch
>>> (which is somewhat large(ish) - I wonder why it has been rolled int=
o
>>> single patch while in reality it consists of 7 commits; and I wonde=
r
>>> why the final result is different from current version in check_pee=
r_redir()
>>> routine, which I mentioned in my other email in this thread), but t=
hat
>>> one does not seem to address this very issue - from a quick view an=
yway.
>>=20
>> That was the tricky part handled by David.
>>=20
>> We couldnt apply all needed commits without bringing too many things
>> from recent kernels to 3.0  (out of stable scope)
>>=20
>> If you believe a fix is needed, just shout :)
>=20
> I think the a fix is needed.  I still don't understand where our
> unexpected redirects are coming from, but we had two more occurences
> of this very issue.  After applying the two patches:
>=20
> 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae route: fix ICMP redirect val=
idation
> 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc ipv4: fix redirect handling

If you were paying attention, you'd see that both of these patches are
in Greg's stable queue already.
