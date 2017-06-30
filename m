From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v5 02/16] bpf: program to load and attach sock_ops
 BPF progs
Date: Sat, 01 Jul 2017 01:33:05 +0200
Message-ID: <5956DFB1.9070005@iogearbox.net>
References: <20170630200706.4183158-1-brakmo@fb.com> <20170630200706.4183158-3-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57204 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751761AbdF3XdH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 19:33:07 -0400
In-Reply-To: <20170630200706.4183158-3-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2017 10:06 PM, Lawrence Brakmo wrote:
> The program load_sock_ops can be used to load sock_ops bpf programs and
> to attach it to an existing (v2) cgroup. It can also be used to detach
> sock_ops programs.
>
> Examples:
>      load_sock_ops [-l] <cg-path> <prog filename>
> 	Load and attaches a sock_ops program at the specified cgroup.
> 	If "-l" is used, the program will continue to run to output the
> 	BPF log buffer.
> 	If the specified filename does not end in ".o", it appends
> 	"_kern.o" to the name.
>
>      load_sock_ops -r <cg-path>
> 	Detaches the currently attached sock_ops program from the
> 	specified cgroup.
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
