From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master 0/2] BPF/XDP json follow-up
Date: Fri, 22 Sep 2017 10:07:55 -0700
Message-ID: <20170922100755.5e2456db@xeon-e3>
References: <cover.1505956723.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:50675 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751877AbdIVRH6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 13:07:58 -0400
Received: by mail-pg0-f50.google.com with SMTP id p5so903524pgn.7
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 10:07:58 -0700 (PDT)
In-Reply-To: <cover.1505956723.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Sep 2017 10:42:27 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> After merging net-next branch into master, Stephen asked to
> fix up json dump for XDP as there were some merge conflicts,
> so here it is.
> 
> Thanks!
> 
> Daniel Borkmann (2):
>   json: move json printer to common library
>   bpf: properly output json for xdp
> 
>  include/json_print.h |  71 ++++++++++++++++
>  ip/Makefile          |   2 +-
>  ip/ip_common.h       |  65 ++------------
>  ip/ip_print.c        | 233 ---------------------------------------------------
>  ip/iplink_xdp.c      |  74 +++++++++-------
>  lib/Makefile         |   2 +-
>  lib/bpf.c            |  19 +++--
>  lib/json_print.c     | 231 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  8 files changed, 369 insertions(+), 328 deletions(-)
>  create mode 100644 include/json_print.h
>  delete mode 100644 ip/ip_print.c
>  create mode 100644 lib/json_print.c
> 

Applied.
