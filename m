From: Andreas Schwab <schwab@suse.de>
Subject: Re: [PATCH] compat bug in sys_recvmsg, MSG_CMSG_COMPAT check
 missing
Date: Sat, 05 Jun 2004 23:47:22 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <jen03h7k45.fsf@sykes.suse.de>
References: <20040605204334.GA1134@suse.de>
	<20040605140153.6c5945a0.davem@redhat.com>
	<20040605140544.0de4034d.davem@redhat.com>
	<jer7st7lam.fsf@sykes.suse.de>
	<20040605143649.3fd6c22b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: olh@suse.de, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262050AbUFEVr0@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040605143649.3fd6c22b.davem@redhat.com> (David S. Miller's
 message of "Sat, 5 Jun 2004 14:36:49 -0700")
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> writes:

> On Sat, 05 Jun 2004 23:21:53 +0200
> Andreas Schwab <schwab@suse.de> wrote:
>
>> "David S. Miller" <davem@redhat.com> writes:
>>=20
>> > This means also that Olaf's patch is broken, when CONFIG_COMPAT is=
 not
>> > set, MSG_CMSG_COMPAT is zero, thus ~MSG_CMSG_COMPAT is the unexpec=
ted
>> > value all 1's thus breaking the tests for unexpected flags complet=
ely.
>>=20
>> ??? Where do you get ~MSG_CMSG_COMPAT from?
>
> Olaf's patch, it said:
>
> -	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC))
> +	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))

Yes, and where is the problem?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
