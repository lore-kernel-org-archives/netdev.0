From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH v2 2/3] rocker: add support for phys_port_name
Date: Mon, 16 Mar 2015 22:52:15 -0700
Message-ID: <CAE4R7bCiOWm423uU=DEoFxJeRpBptM_kYWC9Mm2y_CmpfAK2pQ@mail.gmail.com>
References: <1426562837-13126-1-git-send-email-dsahern@gmail.com>
	<1426562837-13126-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:36397 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbbCQFwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 01:52:16 -0400
Received: by qcto4 with SMTP id o4so64711394qct.3
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 22:52:15 -0700 (PDT)
In-Reply-To: <1426562837-13126-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 8:27 PM, David Ahern <dsahern@gmail.com> wrote:
> Implement the phys_port_name operation. Port names are pulled from the
> rocker hardware model in qemu and default to the qemu name + port id.
> e.g.,
>
> sw1p1: flags=4098<BROADCAST,MULTICAST>  mtu 1500
>         ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
>         RX packets 0  bytes 0 (0.0 B)
>         RX errors 0  dropped 0  overruns 0  frame 0
>         TX packets 0  bytes 0 (0.0 B)
>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
>
> where 'sw1' comes from the qemu command line -device rocker,name=sw1, and
> 'p1' is port 1.
>
> Patch is adapted from Scott's phys_port_id patch.
>
> v2:
> - updated per changes in prior patch requested by Jiri
>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Cc: Scott Feldman <sfeldma@gmail.com>
> Cc: Jiri Pirko <jiri@resnulli.us>

Acked-by: Scott Feldman <sfeldma@gmail.com>
