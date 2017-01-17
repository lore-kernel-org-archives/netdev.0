From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: sparse fixes in
 br_ip6_multicast_alloc_query()
Date: Tue, 17 Jan 2017 08:56:48 -0800
Message-ID: <20170117085648.0c7b4e91@xeon-e3>
References: <1484608295-24250-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34736 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdAQQ5B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:57:01 -0500
Received: by mail-pf0-f180.google.com with SMTP id e4so24897062pfg.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 08:57:01 -0800 (PST)
In-Reply-To: <1484608295-24250-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jan 2017 18:11:35 -0500
Lance Richardson <lrichard@redhat.com> wrote:

> Changed type of csum field in struct igmpv3_query from __be16 to
> __sum16 to eliminate type warning, made same change in struct
> igmpv3_report for consistency.
> 
> Fixed up an ntohs() where htons() should have been used instead.
> 
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
