From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Backport bpf: try harder on clones when writing into skb?
 [Commit: 3697649ff29e0f647565eed04b27a7779c646a22]
Date: Tue, 5 Jul 2016 19:16:51 -0700
Message-ID: <20160706021649.GA82976@ast-mbp.thefacebook.com>
References: <CAMp4zn-MNgqJ1Xzm8JO529=LVyB71bdYaUm0FqyNCMx4Hf+xSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36570 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbcGFCQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 22:16:56 -0400
Received: by mail-pf0-f169.google.com with SMTP id t190so75379830pfb.3
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 19:16:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMp4zn-MNgqJ1Xzm8JO529=LVyB71bdYaUm0FqyNCMx4Hf+xSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2016 at 08:35:18AM -0700, Sargun Dhillon wrote:
> Does it make sense to backport
> 3697649ff29e0f647565eed04b27a7779c646a22 from 4.6 to the longterm
> (4.4) release? I can trivially recreate the issue represented by
> 3697649ff29e0f647565eed04b27a7779c646a22 by attaching a eBPF filter
> that clones an ingress ICMP packet, and then tries to set the
> destination MAC address.
> 
> It seems like the patch applies cleanly to 4.4. I cherry-picked it,
> and rebuilt my kernel, and at least in the trivial test case passes.

Makes sense to me, especially since it's lts.
Daniel, thoughts?
