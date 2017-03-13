From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 05/10] net: vrf: Set slave's private flag before
 linking
Date: Mon, 13 Mar 2017 09:19:24 -0600
Message-ID: <fb8a986d-0f21-74d9-5608-faf4ac8f5ace@cumulusnetworks.com>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33101 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdCMPUT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:20:19 -0400
Received: by mail-pg0-f44.google.com with SMTP id 25so64843197pgy.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 08:19:26 -0700 (PDT)
In-Reply-To: <1489390713-2634-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/17 1:38 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Allow listeners of the subsequent CHANGEUPPER notification to retrieve
> the VRF's table ID by calling l3mdev_fib_table() with the slave netdev.
> Without this change, the netdev won't be considered an L3 slave and the
> function would return 0.
> 
> This is consistent with other master device such as bridge and bond that
> set the slave's private flag before linking. It also makes
> do_vrf_{add,del}_slave() symmetric.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/vrf.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 


Acked-by: David Ahern <dsa@cumulusnetworks.com>
