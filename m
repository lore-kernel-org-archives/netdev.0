From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 1/2] lib names: Split to db_names_alloc and
 db_names_load
Date: Tue, 24 Mar 2015 14:58:51 -0700
Message-ID: <20150324145851.516ca7af@urahara>
References: <1426623342-16470-1-git-send-email-vadim4j@gmail.com>
	<1426623342-16470-2-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34805 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbbCXV6t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 17:58:49 -0400
Received: by pdbni2 with SMTP id ni2so6467423pdb.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 14:58:48 -0700 (PDT)
In-Reply-To: <1426623342-16470-2-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2015 22:15:41 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
>=20
> Also added checking for malloc failing
>=20
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Conceptually I am fine with this, but it doesn't build:

tc_util.c: In function =E2=80=98cls_names_init=E2=80=99:
tc_util.c:40:14: error: too many arguments to function =E2=80=98db_name=
s_alloc=E2=80=99
  cls_names =3D db_names_alloc(path ?: NAMES_DB);
              ^
In file included from tc_util.c:26:0:
=2E./include/names.h:19:18: note: declared here
 struct db_names *db_names_alloc(void);
                  ^
<builtin>: recipe for target 'tc_util.o' failed
make[1]: *** [tc_util.o] Error 1


All patches must build (even if split into two pieces).
