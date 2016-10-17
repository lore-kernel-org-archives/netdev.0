From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/2] bpf: add various tests around spill/fill of
 regs
Date: Mon, 17 Oct 2016 13:44:34 -0700
Message-ID: <20161017204432.GA77495@ast-mbp.thefacebook.com>
References: <cover.1476705709.git.daniel@iogearbox.net>
 <b116029a1133424fdec5ee54cc5bf91968a62463.1476705709.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36601 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932221AbcJQUoZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 16:44:25 -0400
Received: by mail-pf0-f194.google.com with SMTP id r16so13410083pfg.3
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 13:44:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b116029a1133424fdec5ee54cc5bf91968a62463.1476705709.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 02:28:35PM +0200, Daniel Borkmann wrote:
> Add several spill/fill tests. Besides others, one that performs xadd
> on the spilled register, one ldx/stx test where different types are
> spilled from two branches and read out from common path. Verfier does
> handle all correctly.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
