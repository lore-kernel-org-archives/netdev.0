From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: tc_bpf.c: fix building with musl libc
Date: Mon, 11 Apr 2016 15:17:25 -0700
Message-ID: <20160411151725.3748507c@xeon-e3>
References: <1460120373-32096-1-git-send-email-gustavo@zacarias.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Gustavo Zacarias <gustavo@zacarias.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36810 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221AbcDKWRV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 18:17:21 -0400
Received: by mail-pf0-f169.google.com with SMTP id e128so60520pfe.3
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 15:17:21 -0700 (PDT)
In-Reply-To: <1460120373-32096-1-git-send-email-gustavo@zacarias.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  8 Apr 2016 09:59:33 -0300
Gustavo Zacarias <gustavo@zacarias.com.ar> wrote:

> We need limits.h for PATH_MAX, fixes:
>=20
> tc_bpf.c: In function =E2=80=98bpf_map_selfcheck_pinned=E2=80=99:
> tc_bpf.c:222:12: error: =E2=80=98PATH_MAX=E2=80=99 undeclared (first =
use in this
> function)
>   char file[PATH_MAX], buff[4096];
>=20
> Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>

Applied
