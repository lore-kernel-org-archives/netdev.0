From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net PATCH 5/5] bpf: require CAP_NET_ADMIN when using devmap
Date: Wed, 18 Oct 2017 10:34:43 -0700
Message-ID: <20171018173441.6jdwf3dpftt3jv2v@ast-mbp>
References: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
 <150833590435.3588.5261586304462625374.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, borkmann@iogearbox.net
To: John Fastabend <john.r.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:48101 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdJRRep (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 13:34:45 -0400
Received: by mail-pg0-f47.google.com with SMTP id r25so4837605pgn.4
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:34:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150833590435.3588.5261586304462625374.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 07:11:44AM -0700, John Fastabend wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> 
> Devmap is used with XDP which requires CAP_NET_ADMIN so lets also
> make CAP_NET_ADMIN required to use the map.
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
