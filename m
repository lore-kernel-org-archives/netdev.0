From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/4] Add support for dpipe's global header
 formatting
Date: Thu, 7 Sep 2017 15:13:23 -0700
Message-ID: <20170907151323.74aecbdd@xeon-e3>
References: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
        mlxsw@mellanox.com, andrew@lunn.ch
To: Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33861 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932238AbdIGWNZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 18:13:25 -0400
Received: by mail-pg0-f42.google.com with SMTP id q68so1732553pgq.1
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 15:13:25 -0700 (PDT)
In-Reply-To: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Sep 2017 17:26:39 +0300
Arkadi Sharshevsky <arkadis@mellanox.com> wrote:

> Some dpipe's global header values need special formatting, for example
> Ethernet and IP addresses. This patchset adds support for IPv4/6 and
> Ethernet's special format.
> 
> Arkadi Sharshevsky (4):
>   devlink: Make match/action parsing more flexible
>   devlink: Add support for special format protocol headers
>   devlink: Update devlink UAPI file
>   devlink: Add support for protocol IPv4/IPv6/Ethernet special formats
> 
>  devlink/devlink.c       | 319 +++++++++++++++++++++++++++++++++++++-----------
>  include/linux/devlink.h |  18 +++
>  2 files changed, 265 insertions(+), 72 deletions(-)
> 

Applied 1,2 and 4.  #3 was not needed.
