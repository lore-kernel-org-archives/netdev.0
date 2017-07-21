From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master 1/2] bpf: improve error reporting around
 tail calls
Date: Fri, 21 Jul 2017 16:28:25 -0700
Message-ID: <20170721162825.0b42e9ba@xeon-e3>
References: <cover.1500663605.git.daniel@iogearbox.net>
        <b0bf43dac3babbb1a78fabeeb2a3a069db4f262c.1500663605.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35897 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753111AbdGUX2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 19:28:32 -0400
Received: by mail-pf0-f169.google.com with SMTP id o88so28849762pfk.3
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 16:28:32 -0700 (PDT)
In-Reply-To: <b0bf43dac3babbb1a78fabeeb2a3a069db4f262c.1500663605.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Jul 2017 21:13:06 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Currently, it's still quite hard to figure out if a prog passed the
> verifier, but later gets rejected due to different tail call ownership.
> Figure out whether that is the case and provide appropriate error
> messages to the user.
>=20
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Sorry, dead code. Please fix and resubmit.

bpf.c:356:12: warning: =E2=80=98bpf_derive_prog_from_fdinfo=E2=80=99 define=
d but not used [-Wunused-function]
 static int bpf_derive_prog_from_fdinfo(int fd, struct bpf_prog_data *prog)
