From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 5/6] bpf, nfp: add meta data support
Date: Mon, 25 Sep 2017 12:12:53 +0100
Message-ID: <20170925121253.4c0e3188@cakuba>
References: <cover.1506297988.git.daniel@iogearbox.net>
        <e88b1cbcb0cbfb20a960c57cee3c873e3cadc4cb.1506297988.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, peter.waskiewicz.jr@intel.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:31140 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933062AbdIYLNA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 07:13:00 -0400
In-Reply-To: <e88b1cbcb0cbfb20a960c57cee3c873e3cadc4cb.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Sep 2017 02:25:54 +0200, Daniel Borkmann wrote:
> Implement support for transferring XDP meta data into skb for
> nfp driver; before calling into the program, xdp.data_meta points
> to xdp.data, where on program return with pass verdict, we call
> into skb_metadata_set().
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: John Fastabend <john.fastabend@gmail.com>

Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Thanks!
