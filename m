From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] bridge: vlan: Use rcu_dereference instead of
 rtnl_dereference
Date: Mon, 2 Nov 2015 09:40:40 +0100
Message-ID: <20151102084040.GB2216@nanopsycho.orion>
References: <1446395505-24841-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, nikolay@cumulusnetworks.com,
	jiri@mellanox.com, eladr@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34562 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbbKBIkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 03:40:43 -0500
Received: by wikq8 with SMTP id q8so46260837wik.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 00:40:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1446395505-24841-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Nov 01, 2015 at 05:31:45PM CET, idosch@mellanox.com wrote:
>br_should_learn() is protected by RCU and not by RTNL, so use correct
>flavor of nbp_vlan_group().
>
>Fixes: 907b1e6e83ed ("bridge: vlan: use proper rcu for the vlgrp
>member")
>Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
