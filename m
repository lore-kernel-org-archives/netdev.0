From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 2/8] xdp: add HW offload mode flag for installing
 programs
Date: Tue, 20 Jun 2017 01:39:18 +0200
Message-ID: <594860A6.1010301@iogearbox.net>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com> <20170616235746.16337-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, netoptimizer@brouer.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32975 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753074AbdFSXjW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 19:39:22 -0400
In-Reply-To: <20170616235746.16337-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2017 01:57 AM, Jakub Kicinski wrote:
> Add an installation-time flag for requesting that the program
> be installed only if it can be offloaded to HW.
>
> Internally new command for ndo_xdp is added, this way we avoid
> putting checks into drivers since they all return -EINVAL on
> an unknown command.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
