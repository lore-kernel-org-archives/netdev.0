From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH iproute2 -next] f_bpf: allow for optional classid and add
 flags
Date: Fri, 25 Sep 2015 07:58:39 -0700
Message-ID: <5605611F.3030806@plumgrid.com>
References: <efad6a0f1fc08df554d5b0d0b36fb3dde4afe131.1443176477.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33926 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbbIYO6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:58:44 -0400
Received: by ykdg206 with SMTP id g206so115553204ykd.1
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:58:43 -0700 (PDT)
In-Reply-To: <efad6a0f1fc08df554d5b0d0b36fb3dde4afe131.1443176477.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/25/15 3:32 AM, Daniel Borkmann wrote:
> When having optional classid, most minimal command can be sth
> like:
>
>    tc filter add dev foo parent X: bpf obj prog.o
>
> Therefore, adapt the code so that a next argument will not be
> enforced as the case currently.
>
> Also, minor cleanup on the classid, where we should rather
> have used addattr32(), and add flags for exec configuration,
> for example (using short notation):
>
>    tc filter add dev foo parent X: bpf da obj prog.o
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
