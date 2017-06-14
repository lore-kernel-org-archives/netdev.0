From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] iproute: Remove useless check for nexthop
 keyword when setting RTA_OIF
Date: Wed, 14 Jun 2017 09:57:09 -0700
Message-ID: <20170614095709.46aac3e0@xeon-e3>
References: <20170607132313.5290-1-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jakub Sitnicki <jkbs@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34685 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbdFNQ5M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 12:57:12 -0400
Received: by mail-pf0-f169.google.com with SMTP id s66so3078427pfs.1
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 09:57:12 -0700 (PDT)
In-Reply-To: <20170607132313.5290-1-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Jun 2017 15:23:13 +0200
Jakub Sitnicki <jkbs@redhat.com> wrote:

> When modifying a route we set the RTA_OIF attribute only if a device was
> specified with "dev" or "oif" keyword. But for some unknown reason we
> earlier alternatively check also for the presence of "nexthop" keyword,
> even though it has no effect. So remove the pointless check.
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Makes sense, applied.
