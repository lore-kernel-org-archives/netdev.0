From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rtnetlink: Remove NETDEV_CHANGEINFODATA
Date: Sat, 29 Apr 2017 00:36:02 +0200
Message-ID: <20170428223602.GC1905@nanopsycho.orion>
References: <1493402785-18844-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38260 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2997449AbdD1WgF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 18:36:05 -0400
Received: by mail-wm0-f49.google.com with SMTP id r190so58730147wme.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 15:36:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1493402785-18844-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 28, 2017 at 08:06:25PM CEST, dsa@cumulusnetworks.com wrote:
>NETDEV_CHANGEINFODATA was added by d4261e5650004 ("bonding: create
>netlink event when bonding option is changed"). RTM_NEWLINK
>messages are already created on changelink events, so this event
>is just a duplicate. Remove it.
>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
