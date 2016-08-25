From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute] iptuntap: show processes using tuntap interface
Date: Thu, 25 Aug 2016 08:44:24 -0700
Message-ID: <20160825084424.73a31b8a@xeon-e3>
References: <1472062105-17995-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33182 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759965AbcHYPoM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 11:44:12 -0400
Received: by mail-pf0-f180.google.com with SMTP id y134so18873581pfg.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 08:44:12 -0700 (PDT)
In-Reply-To: <1472062105-17995-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Aug 2016 20:08:25 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> Show which processes are using which tun/tap devices, e.g.:
> 
> $ ip -d tuntap
> tun0: tun
> 	Attached to processes: vpnc(9531)
> vnet0: tap vnet_hdr
> 	Attached to processes: qemu-system-x86(10442)
> virbr0-nic: tap UNKNOWN_FLAGS:800
> 	Attached to processes:
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I think reading all of /proc like this will scale really badly on large systems.
Why reinvent lsof?
