From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Fri, 07 Jul 2017 10:48:36 -0700
Message-ID: <595FC974.9030807@gmail.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, andy@greyhouse.net, daniel@iogearbox.net,
        ast@fb.com, Alexander Duyck <alexander.duyck@gmail.com>,
        bjorn.topel@intel.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        ecree@solarflare.com, sgoutham@cavium.com, Yuval.Mintz@cavium.com,
        saeedm@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34540 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751812AbdGGRtD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 13:49:03 -0400
Received: by mail-pg0-f47.google.com with SMTP id t186so20579316pgb.1
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 10:48:58 -0700 (PDT)
In-Reply-To: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2017 10:34 AM, John Fastabend wrote:
> This series adds two new XDP helper routines bpf_redirect() and
> bpf_redirect_map(). The first variant bpf_redirect() is meant
> to be used the same way it is currently being used by the cls_bpf
> classifier. An xdp packet will be redirected immediately when this
> is called.

Also other than the typo in the title there ;) I'm going to CC
the driver maintainers working on XDP (makes for a long CC list but)
because we would want to try and get support in as many as possible in
the next merge window.

For this rev I just implemented on ixgbe because I wrote the
original XDP support there. I'll volunteer to do virtio as well.

Thanks,
John
