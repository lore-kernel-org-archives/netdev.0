From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute] iptuntap: show processes using tuntap interface
Date: Thu, 1 Sep 2016 09:06:21 -0700
Message-ID: <20160901090621.13026e9c@xeon-e3>
References: <1472062105-17995-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35948 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934214AbcIAQGK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 12:06:10 -0400
Received: by mail-pf0-f174.google.com with SMTP id h186so32684967pfg.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 09:06:10 -0700 (PDT)
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

Applied, but needed a followon change to fix some style issues.
