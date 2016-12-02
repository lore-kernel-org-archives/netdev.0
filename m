From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next] ss: initialise variables outside of
 for loop
Date: Fri, 2 Dec 2016 14:18:17 -0800
Message-ID: <20161202141817.7341a497@xeon-e3>
References: <1480679765-9014-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33572 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753035AbcLBWZg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:25:36 -0500
Received: by mail-pg0-f43.google.com with SMTP id 3so111917005pgd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:25:36 -0800 (PST)
In-Reply-To: <1480679765-9014-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Dec 2016 12:56:05 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Initialise for loops outside of for loops. GCC flags this as being
> out of spec unless C99 or C11 mode is used.
>=20
> With this change the entire tree appears to compile cleanly with -Wall.
>=20
> $ gcc --version
> gcc (Debian 4.9.2-10) 4.9.2
> ...
> $ make
> ...
> ss.c: In function =E2=80=98unix_show_sock=E2=80=99:
> ss.c:3128:4: error: =E2=80=98for=E2=80=99 loop initial declarations are o=
nly allowed in C99 or C11 mode
> ...
>=20
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied.
Note, I used to have -Wall in Makefile but old GCC were broken and would gi=
ve
aliasing warnings.
