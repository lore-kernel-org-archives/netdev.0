From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/3] ip-link: XDP flags and offload mode
Date: Tue, 27 Jun 2017 16:15:51 -0700
Message-ID: <20170627161551.66f54084@xeon-e3>
References: <20170627002353.12292-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36392 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753959AbdF0XPx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:15:53 -0400
Received: by mail-pf0-f182.google.com with SMTP id q86so23635388pfl.3
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:15:53 -0700 (PDT)
In-Reply-To: <20170627002353.12292-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Jun 2017 17:23:50 -0700
Jakub Kicinski <jakub.kicinski@netronome.com> wrote:

> Hi!
> 
> This series adds support for specifying DRV_MODE and new HW_MODE
> flags when binding an XDP program to the driver.  It also teaches
> ip link about "xdpoffload" attachment mode.
> 
> Examples:
> # ip link set dev p4p1 xdpoffload obj prog.o sec '.text'
> # ip link show dev p4p1
> 60: p4p1: <BROADCAST,MULTICAST> mtu 1500 xdpoffload/id:2 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether 00:15:4d:12:27:6b brd ff:ff:ff:ff:ff:ff
> # ip link set dev p4p1 xdpoffload off
> 
> Note: this is based on top of Martin's "bpf: Add support for 
> IFLA_XDP_PROG_ID".
> 
> Jakub Kicinski (3):
>   bpf: print xdp offloaded mode
>   bpf: add xdpdrv for requesting XDP driver mode
>   bpf: allow requesting XDP HW offload
> 
>  include/linux/if_link.h |  2 ++
>  ip/iplink.c             |  7 ++++++-
>  ip/iplink_xdp.c         |  9 ++++++++-
>  ip/xdp.h                |  3 ++-
>  man/man8/ip-link.8.in   | 13 ++++++++++++-
>  5 files changed, 30 insertions(+), 4 deletions(-)
> 

Applied to net-next.
Next time please put net-next in the patch subject line (same as for kernel).
