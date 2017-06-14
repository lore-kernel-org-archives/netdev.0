From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] ip neigh: allow flush FAILED
 neighbour entry
Date: Wed, 14 Jun 2017 09:54:50 -0700
Message-ID: <20170614095450.3c9b5dcb@xeon-e3>
References: <1496651489-28110-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36583 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdFNQy5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 12:54:57 -0400
Received: by mail-pg0-f42.google.com with SMTP id a70so2699545pge.3
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 09:54:57 -0700 (PDT)
In-Reply-To: <1496651489-28110-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  5 Jun 2017 16:31:29 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> After upstream commit 5071034e4af7 ('neigh: Really delete an arp/neigh entry
> on "ip neigh delete" or "arp -d"'), we could delete a single FAILED neighbour
> entry now. But `ip neigh flush` still skip the FAILED entry.
> 
> Let's remove this filter so we can also flush FAILED entry.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

This might create a problem. iproute2 has to be forward/backwards compatiable
with multiple kernel versions. Users must be able to run newer versions of ip
command on older kernels.

What happens if you run the ip command with your patch on older kernels?
