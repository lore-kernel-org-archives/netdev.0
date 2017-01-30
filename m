From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v5 2/4] ifstat: Add extended statistics to
 ifstat
Date: Sun, 29 Jan 2017 20:34:25 -0800
Message-ID: <20170129203425.070a27d6@xeon-e3>
References: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
        <1485434681-33947-3-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        roszenrami@gmail.com, jbenc@redhat.com,
        sergei.shtylyov@cogentembedded.com, jiri@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35417 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdA3Ef7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 23:35:59 -0500
Received: by mail-pg0-f53.google.com with SMTP id 194so97689176pgd.2
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 20:34:32 -0800 (PST)
In-Reply-To: <1485434681-33947-3-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jan 2017 14:44:39 +0200
Nogah Frankel <nogahf@mellanox.com> wrote:

> Extended stats are part of the RTM_GETSTATS method. This patch adds them
> to ifstat.
> While extended stats can come in many forms, we support only the
> rtnl_link_stats64 struct for them (which is the 64 bits version of struct
> rtnl_link_stats).
> We support stats in the main nesting level, or one lower.
> The extension can be called by its name or any shorten of it. If there is
> more than one matched, the first one will be picked.
> 
> To get the extended stats the flag -x <stats type> is used.

It would be better if this command used 64 bit statistics transparently
like other tools in iproute2. Transparency is always better user experience.
