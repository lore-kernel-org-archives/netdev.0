From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 3/3] tools: bpftool: optionally show filenames
 of pinned objects
Date: Tue, 31 Oct 2017 10:37:39 -0700
Message-ID: <20171031103739.03cd28ee@cakuba.netronome.com>
References: <20171031073632.8140-1-bhole_prashant_q7@lab.ntt.co.jp>
        <20171031073632.8140-4-bhole_prashant_q7@lab.ntt.co.jp>
        <6bf809f2-acb5-4615-bb63-24325b967d12@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Quentin Monnet <quentin.monnet@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:47480 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753711AbdJaRhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:37:43 -0400
Received: by mail-qt0-f170.google.com with SMTP id z50so21733756qtj.4
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 10:37:43 -0700 (PDT)
In-Reply-To: <6bf809f2-acb5-4615-bb63-24325b967d12@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 11:54:20 +0000, Quentin Monnet wrote:
> > @@ -265,6 +266,7 @@ int main(int argc, char **argv)
> >  		{ "help",	no_argument,	NULL,	'h' },
> >  		{ "pretty",	no_argument,	NULL,	'p' },
> >  		{ "version",	no_argument,	NULL,	'V' },
> > +		{ "pinned",	no_argument,	NULL,	'l' }, =20
>=20
> =E2=80=9Cl=E2=80=9D is not especially easy to remember for =E2=80=9Cpinne=
d=E2=80=9D, but I don't see a
> good alternative, so fine by me (uppercase =E2=80=9CP=E2=80=9D may not ma=
ke things any
> better I suppose).

Since -p is taken maybe something to do with bpffs instead of pinned?
--bpffs | -b or -f?
