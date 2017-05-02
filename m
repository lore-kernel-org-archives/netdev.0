From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next iproute2 1/3] netlink: import netlink message
 parsing from kernel
Date: Tue, 2 May 2017 08:25:31 -0700
Message-ID: <20170502082531.43b32e05@xeon-e3>
References: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
        <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35997 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750724AbdEBPZe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:25:34 -0400
Received: by mail-pf0-f173.google.com with SMTP id q66so46454797pfi.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:25:34 -0700 (PDT)
In-Reply-To: <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  1 May 2017 20:18:23 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> include/nlattr.h is pulled from include/net/netlink.h.
> lib/nlattr.c is pulled from lib/nlattr.c
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

No. I am not taking a third way of parsing netlink attributes.


Please either use existing netlink attribute code in libnetlink.h
(rta_getattr_u32 etc) or use libmnl like devlink.
