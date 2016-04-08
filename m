From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] iproute2: tc_bpf.c: fix building with musl libc
Date: Fri, 08 Apr 2016 15:14:37 +0200
Message-ID: <5707AEBD.4050101@iogearbox.net>
References: <1460120373-32096-1-git-send-email-gustavo@zacarias.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gustavo Zacarias <gustavo@zacarias.com.ar>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46759 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754297AbcDHNOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 09:14:45 -0400
In-Reply-To: <1460120373-32096-1-git-send-email-gustavo@zacarias.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2016 02:59 PM, Gustavo Zacarias wrote:
> We need limits.h for PATH_MAX, fixes:
>
> tc_bpf.c: In function =E2=80=98bpf_map_selfcheck_pinned=E2=80=99:
> tc_bpf.c:222:12: error: =E2=80=98PATH_MAX=E2=80=99 undeclared (first =
use in this
> function)
>    char file[PATH_MAX], buff[4096];
>
> Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>

=46ine with me, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
