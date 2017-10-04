From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 6/7] net: bridge: Pass extack to down to
 netdev_master_upper_dev_link
Date: Wed, 4 Oct 2017 08:13:57 -0700
Message-ID: <20171004081357.37bfd941@xeon-e3>
References: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
        <1507093134-20406-7-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, jiri@mellanox.com, idosch@mellanox.com,
        davem@davemloft.net, bridge@lists.linux-foundation.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:44388 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752405AbdJDPOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 11:14:05 -0400
Received: by mail-pf0-f182.google.com with SMTP id t62so5213250pfd.1
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 08:14:05 -0700 (PDT)
In-Reply-To: <1507093134-20406-7-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  3 Oct 2017 21:58:53 -0700
David Ahern <dsahern@gmail.com> wrote:

> Pass extack arg to br_add_if. Add messages for a couple of failures
> and pass arg to netdev_master_upper_dev_link.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

This looks good. You might want to pass the netlink_ext_ack down as
an immutable pointer (const).

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
