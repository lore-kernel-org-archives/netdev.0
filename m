From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 iproute2 net-next] ip neigh: allow flush FAILED
 neighbour entry
Date: Fri, 16 Jun 2017 09:01:30 -0700
Message-ID: <20170616090130.78045dcb@xeon-e3>
References: <1496651489-28110-1-git-send-email-liuhangbin@gmail.com>
        <1497583912-27981-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34688 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752134AbdFPQBj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:01:39 -0400
Received: by mail-pf0-f169.google.com with SMTP id s66so24276130pfs.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 09:01:39 -0700 (PDT)
In-Reply-To: <1497583912-27981-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Jun 2017 11:31:52 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> After upstream commit 5071034e4af7 ('neigh: Really delete an arp/neigh entry
> on "ip neigh delete" or "arp -d"'), we could delete a single FAILED neighbour
> entry now. But `ip neigh flush` still skip the FAILED entry.
> 
> Move the filter after first round flush so we can flush FAILED entry on fixed
> kernel and also do not keep retrying on old kernel.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied, thanks.
