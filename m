From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 7/8] xdp: add reporting of offload mode
Date: Tue, 20 Jun 2017 01:40:14 +0200
Message-ID: <594860DE.20205@iogearbox.net>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com> <20170616235746.16337-8-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, netoptimizer@brouer.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33059 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753127AbdFSXkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 19:40:19 -0400
In-Reply-To: <20170616235746.16337-8-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2017 01:57 AM, Jakub Kicinski wrote:
> Extend the XDP_ATTACHED_* values to include offloaded mode.
> Let drivers report whether program is installed in the driver
> or the HW by changing the prog_attached field from bool to
> u8 (type of the netlink attribute).
>
> Exploit the fact that the value of XDP_ATTACHED_DRV is 1,
> therefore since all drivers currently assign the mode with
> double negation:
>         mode = !!xdp_prog;
> no drivers have to be modified.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
