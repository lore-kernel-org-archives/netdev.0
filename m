From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v9 00/11] Add driver bpf hook for early packet drop and
 forwarding
Date: Mon, 18 Jul 2016 09:38:28 -0700
Message-ID: <20160718163827.GA29243@gmail.com>
References: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
 <f94302fd-da02-c03d-e9ab-5292e6594b10@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35599 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbcGRQie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 12:38:34 -0400
Received: by mail-pf0-f177.google.com with SMTP id x72so6833585pfd.2
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 09:38:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f94302fd-da02-c03d-e9ab-5292e6594b10@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 04:39:38PM +0300, Tariq Toukan wrote:
> After applying the patchset, I get no ping between two VLAN
> interfaces (w/o activating any BPF program).
> I'm debugging it, and will update once I find the bug.
> 
> Brenden, please check if you can repro the issue.
I was able to reproduce it also. I suspect a bug in patch 8/11.
> 
> Regards,
> Tariq
> 
