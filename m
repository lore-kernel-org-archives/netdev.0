From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/3] powerpc: bpf: remove redundant check for non-null
 image
Date: Fri, 13 Jan 2017 12:09:47 -0800
Message-ID: <20170113200945.GA60330@ast-mbp.thefacebook.com>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        davem@davemloft.net
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35579 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbdAMUJx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 15:09:53 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so9662491pfa.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:09:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 10:40:00PM +0530, Naveen N. Rao wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> 
> We have a check earlier to ensure we don't proceed if image is NULL. As
> such, the redundant check can be removed.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> [Added similar changes for classic BPF JIT]
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
