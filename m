From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next RFC 1/2] flow_dissecror: Move ARP dissection
 into a separate function
Date: Tue, 21 Feb 2017 13:32:35 -0500 (EST)
Message-ID: <20170221.133235.262226849361587925.davem@davemloft.net>
References: <20170221143141.GD2694@nanopsycho.mtl.com>
        <1487687599-5464-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
        simon.horman@netronome.com, eric.dumazet@gmail.com,
        dinan.gunawardena@netronome.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752863AbdBUSci (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:32:38 -0500
In-Reply-To: <1487687599-5464-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 21 Feb 2017 15:33:18 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Make the main flow_dissect function a bit smaller and move the ARP
> dissection into a separate function. Along with that, do the ARP header
> processing only in case the flow dissection user requires it.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

These two changes look fine to me, although I hope that the compiler
doesn't decide to inline it anyways.
