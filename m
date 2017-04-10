From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v3 0/2] bridge: Fix kernel oops during bridge
 creation
Date: Mon, 10 Apr 2017 16:06:01 -0400
Message-ID: <20170410160601.67120d94@plumbers-lap.home.lan>
References: <20170410115928.9344-1-idosch@idosch.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, mlxsw@mellanox.com,
        peter@svinota.eu, nikolay@cumulusnetworks.com,
        Ido Schimmel <idosch@mellanox.com>
To: idosch@idosch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36623 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751890AbdDJUGF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 16:06:05 -0400
Received: by mail-qk0-f182.google.com with SMTP id d131so10176420qkc.3
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 13:06:05 -0700 (PDT)
In-Reply-To: <20170410115928.9344-1-idosch@idosch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Apr 2017 14:59:26 +0300
idosch@idosch.org wrote:

> From: Ido Schimmel <idosch@mellanox.com>
> 
> First patch adds a missing ndo_uninit() in the bridge driver, which is a
> prerequisite for the second patch that actually fixes the oops.
> 
> Please consider both patches for 4.4.y, 4.9.y and 4.10.y
> 
> Ido Schimmel (2):
>   bridge: implement missing ndo_uninit()
>   bridge: netlink: register netdevice before executing changelink
> 
>  net/bridge/br_device.c    | 20 +++++++++++---------
>  net/bridge/br_if.c        |  1 -
>  net/bridge/br_multicast.c |  7 +++++--
>  net/bridge/br_netlink.c   |  7 +++++--
>  net/bridge/br_private.h   |  5 +++++
>  5 files changed, 26 insertions(+), 14 deletions(-)
> 

Looks good, thanks for following through on this.

Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
