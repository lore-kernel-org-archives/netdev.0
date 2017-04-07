From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/5] qede: support XDP head adjustments
Date: Fri, 07 Apr 2017 16:02:14 +0200
Message-ID: <58E79BE6.2070609@iogearbox.net>
References: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com
To: Yuval Mintz <Yuval.Mintz@cavium.com>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46801 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933348AbdDGOCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 10:02:21 -0400
In-Reply-To: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2017 10:04 AM, Yuval Mintz wrote:
> Daniel has brought to my attention the fact that qede is the only driver
> that currently supports XDP but still fails any program where
> xdp_adjust_head is set on the bpf_prog. This series is meant to remedy
> this and align qede with the rest of the driver, making it possible to
> remove said field.

Awesome, thanks a lot Yuval!
