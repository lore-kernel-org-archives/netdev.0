From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/2] ebpf: add helper to retrieve net_cls's
 classid cookie
Date: Wed, 15 Jul 2015 14:06:22 -0700
Message-ID: <55A6CB4E.1080307@plumgrid.com>
References: <cover.1436961536.git.daniel@iogearbox.net>
 <9862a6b8778d344e8e10380060f09b161caac12f.1436961536.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33778 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbbGOVGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 17:06:21 -0400
Received: by pdbqm3 with SMTP id qm3so31236082pdb.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 14:06:21 -0700 (PDT)
In-Reply-To: <9862a6b8778d344e8e10380060f09b161caac12f.1436961536.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/15/15 5:21 AM, Daniel Borkmann wrote:
> It would be very useful to retrieve the net_cls's classid from an eBPF
> program to allow for a more fine-grained classification, it could be
> directly used or in conjunction with additional policies. I.e. docker,
> but also tooling such as cgexec, can easily run applications via net_cls
> cgroups:
>
>    cgcreate -g net_cls:/foo
>    echo 42 > foo/net_cls.classid
>    cgexec -g net_cls:foo <prog>
>
> Thus, their respecitve classid cookie of foo can then be looked up on
> the egress path to apply further policies. The helper is desigend such
> that a non-zero value returns the cgroup id.
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
> Cc: Thomas Graf<tgraf@suug.ch>

looks good to me.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
