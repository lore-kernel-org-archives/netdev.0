From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few minutes
 of heavy surfing
Date: Tue, 08 Dec 2009 12:21:12 +0100
Message-ID: <4B1E36A8.5040106@gmail.com>
References: <335647.4861.qm@web52906.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46326 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbZLHLV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 06:21:57 -0500
In-Reply-To: <335647.4861.qm@web52906.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Rankin a =C3=A9crit :
> --- On Tue, 8/12/09, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Its all two years old UDP bugs (I spot another one some
>> hours ago), and very rare.
>=20
>> I am quite suprised it could happen on your machine on
>> demand.
>=20
> Who said anything about "on demand"? It took about 30 minutes to free=
ze last time;=20
> I was starting to think that a complete recompile had fixed it!
>=20

30 minutes is pretty fast, this is why I said 'on demand'...

> For the record: I've only seen that dmesg warning I've reported *once=
*, and that didn't kill the machine immediately (hence I was able to re=
port it in the first place).
>=20
>> 1) Do you have another NIC adapter to try ? It might be a
>> buggy driver. (Neil Horman found an error on Intel drivers some
>> hours ago, that can corrupt skbs)
>=20
> I can test any patches for a e1000 that apply to 2.6.31.x. But the e1=
000 is an on-board device and I don't have another. But Fedora's 2.6.31=
=2Ex kernels seem OK.
>=20
>> 2) Could you add following debugging aid ?
>=20
> Not a problem; I do have a serial console attached.
>=20
>> 3) Any chance you can do a git bisect ?
>=20
> How do you git-bisect a bug that you can't reproduce on demand? A neg=
ative is easy to spot, but a positive would be not experiencing a rando=
m freeze. As I said, I *almost* thought that I'd resolved the issue by =
recompiling last night.
>=20

Please fold your lines length to < 70=20

If Fedora kernel works, either its just pure luck, or they found
a bug and they didnt sent the fix to mainline (unlikely)


