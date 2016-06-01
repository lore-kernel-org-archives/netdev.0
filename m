From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC 12/12] nfp: bpf: add denser mode of execution
Date: Wed, 1 Jun 2016 15:01:16 -0700
Message-ID: <20160601220114.GC24671@ast-mbp.thefacebook.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-13-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36633 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbcFAWBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 18:01:21 -0400
Received: by mail-pa0-f52.google.com with SMTP id eu11so76892pad.3
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 15:01:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1464799814-4453-13-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2016 at 05:50:14PM +0100, Jakub Kicinski wrote:
> If BPF uses less than 7 registers programmable engines
> can process twice as many packets in parallel.  Signal
> this denser mode of operation to FW by setting the lowest
> bit in DMA address of the machine code buffer.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

wow. that sounds pretty cool.
I was about to ask whether we can help HW to be more efficient
by doing something on bpf side like annotating the registers or
adding 'hw_only' registers...
but looks like less registers is actually good, since NFP jit
can parallelize it? Truly wow.
if you can share the hw architecture details and explain more
on how this 'dense_mode' works, would be awesome.
