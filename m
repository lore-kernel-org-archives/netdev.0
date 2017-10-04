From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next v3 3/3] tools: bpftool: add documentation
Date: Wed, 4 Oct 2017 20:36:42 +0200
Message-ID: <20171004203642.699f5f1a@redhat.com>
References: <20171004154032.11413-1-jakub.kicinski@netronome.com>
        <20171004154032.11413-4-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        dsahern@gmail.com, oss-drivers@netronome.com,
        David Beckett <david.beckett@netronome.com>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750787AbdJDSgv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 14:36:51 -0400
In-Reply-To: <20171004154032.11413-4-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 Oct 2017 08:40:32 -0700
Jakub Kicinski <jakub.kicinski@netronome.com> wrote:

> Add documentation for bpftool.  Separate files for each subcommand.
> Use rst format.  Documentation is compiled into man pages using
> rst2man.
> 
> Signed-off-by: David Beckett <david.beckett@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  tools/bpf/bpftool/Documentation/Makefile         |  34 +++++++
>  tools/bpf/bpftool/Documentation/bpftool-map.txt  | 110 +++++++++++++++++++++++
>  tools/bpf/bpftool/Documentation/bpftool-prog.txt |  79 ++++++++++++++++
>  tools/bpf/bpftool/Documentation/bpftool.txt      |  34 +++++++

RST-format files are usually called .rst and not .txt

This is useful when people happen to browse the code via github, then they get formatted nicely e.g.:
 https://github.com/torvalds/linux/blob/master/samples/bpf/README.rst
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
