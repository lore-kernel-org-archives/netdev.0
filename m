From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next iproute2 1/3] netlink: import netlink message
 parsing from kernel
Date: Tue, 2 May 2017 10:51:23 -0600
Message-ID: <7fa44ec5-9a3a-55d1-b058-540d37ef01bd@cumulusnetworks.com>
References: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
 <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
 <20170502082531.43b32e05@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33632 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdEBQvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 12:51:39 -0400
Received: by mail-pg0-f50.google.com with SMTP id y4so58891910pge.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 09:51:39 -0700 (PDT)
In-Reply-To: <20170502082531.43b32e05@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/17 9:25 AM, Stephen Hemminger wrote:
> Please either use existing netlink attribute code in libnetlink.h
> (rta_getattr_u32 etc) or use libmnl like devlink.

All of the existing rta_ functions take a struct rta_attr; netlink
messages use struct nlattr. It's just wrong to use rta functions for
netlink messages.

There is no existing parse function for nlattr. There is no existing
validate function - for nlattr or rta_attr. So I do not see any overlap
with existing code.

If you prefer ip to gain a dependency on libmnl, I'll take a look.
