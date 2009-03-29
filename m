From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netfilter: fix endian bug in conntrack printks
Date: Sat, 28 Mar 2009 23:56:24 -0700 (PDT)
Message-ID: <20090328.235624.189705273.davem@davemloft.net>
References: <1238290710.3492.8.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751072AbZC2G4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 02:56:36 -0400
In-Reply-To: <1238290710.3492.8.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Sat, 28 Mar 2009 18:38:30 -0700

> dcc_ip is treated as a host-endian value in the first printk,
> but the second printk uses %pI4 which expects a be32.  This
> will cause a mismatch between the debug statement and the
> warning statement.
> 
> Treat as a be32 throughout and avoid some byteswapping during
> some comparisions, and allow another user of HIPQUAD to bite the
> dust.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.

> +			
   ^^^^^^
> +			pr_debug("DCC bound ip/port: %pI4:%u\n",
> +				 &dcc_ip, dcc_port);

Trailing whitespace.
