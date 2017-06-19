From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 2/8] xdp: add HW offload mode flag for installing
 programs
Date: Tue, 20 Jun 2017 01:36:21 +0200
Message-ID: <59485FF5.7010308@iogearbox.net>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>       <20170616235746.16337-3-jakub.kicinski@netronome.com>   <5948566D.40803@iogearbox.net> <20170619162455.466ca63e@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kafai@fb.com,
        oss-drivers@netronome.com, brouer@redhat.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60917 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752289AbdFSXg3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 19:36:29 -0400
In-Reply-To: <20170619162455.466ca63e@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2017 01:24 AM, Jakub Kicinski wrote:
[...]
> The XDP_SETUP_PROG_HW command is purely for convenience of drivers
> without an offload.  I felt it's not appropriate to burden all drivers
> with:
>
> if (xdp->flags & XDP_FLAGS_HW_MODE)
> 	return -EOPNOTSUPP;
>
> But, I do have a patch which does it, so I'm happy to drop the new
> command if it's preferred.

Ahh, that makes sense, yep. I was only focused on reviewing this in
the context of nfp driver. Lack of coffee. ;)
