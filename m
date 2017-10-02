From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [BUG] bpf is broken in net-next
Date: Mon, 2 Oct 2017 07:52:30 -0700
Message-ID: <20171002075230.60d36532@xeon-e3>
References: <20171001140230.6a494b48@xeon-e3>
        <20171002013424.tlaictbu7btc4z56@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:51560 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdJBOwi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 10:52:38 -0400
Received: by mail-pg0-f52.google.com with SMTP id u144so393632pgb.8
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 07:52:38 -0700 (PDT)
In-Reply-To: <20171002013424.tlaictbu7btc4z56@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 1 Oct 2017 18:34:25 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Sun, Oct 01, 2017 at 02:02:30PM -0700, Stephen Hemminger wrote:
> > Recent regression in net-next building bpf.c in samples/bpf now broken.
> >=20
> > $ make samples/bpf/
> >=20
> >=20
> >   HOSTCC  samples/bpf/../../tools/lib/bpf/bpf.o
> > samples/bpf/../../tools/lib/bpf/bpf.c: In function =E2=80=98bpf_create_=
map_node=E2=80=99:
> > samples/bpf/../../tools/lib/bpf/bpf.c:76:13: error: =E2=80=98union bpf_=
attr=E2=80=99 has no member named =E2=80=98map_name=E2=80=99; did you mean =
=E2=80=98map_type=E2=80=99?
> >   memcpy(attr.map_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));
> >              ^
> > samples/bpf/../../tools/lib/bpf/bpf.c:76:44: error: =E2=80=98BPF_OBJ_NA=
ME_LEN=E2=80=99 undeclared (first use in this function)
> >   memcpy(attr.map_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1)); =20
>=20
> everything works fine for me...
> did you do 'make headers_install' ?
>=20

Yes, that was the problem. I had done make mrproper after changing branches.
