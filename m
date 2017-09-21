From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 0/4] cxgb4: add support to offload tc flower
Date: Thu, 21 Sep 2017 10:56:57 +0200
Message-ID: <20170921085657.GB2028@nanopsycho>
References: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kumaras@chelsio.com,
        ganeshgr@chelsio.com, nirranjan@chelsio.com, indranil@chelsio.com
To: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:56394 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdIUI47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 04:56:59 -0400
Received: by mail-wr0-f174.google.com with SMTP id r74so3983010wrb.13
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 01:56:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 21, 2017 at 09:33:33AM CEST, rahul.lakkireddy@chelsio.com wrote:
>This series of patches add support to offload tc flower onto Chelsio
>NICs.
>
>Patch 1 adds basic skeleton to prepare for offloading tc flower flows.
>
>Patch 2 adds support to add/remove flows for offload.  Flows can have
>accompanying masks.  Following match and action are currently supported
>for offload:
>Match:  ether-protocol, IPv4/IPv6 addresses, L4 ports (TCP/UDP)
>Action: drop, redirect to another port on the device.
>
>Patch 3 adds support to offload tc-flower flows having
>vlan actions: pop, push, and modify.
>
>Patch 4 adds support to fetch stats for the offloaded tc flower flows
>from hardware.
>
>Support for offloading more match and action types are to be followed
>in subsequent series.

Looks good to me. Thanks!
