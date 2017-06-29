From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: constify attribute_group structures.
Date: Thu, 29 Jun 2017 15:49:57 -0400 (EDT)
Message-ID: <20170629.154957.2190147576942103077.davem@davemloft.net>
References: <7e920337fab72cc388b20ac95c2e198b84145483.1498733815.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mingo@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753285AbdF2TuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:50:09 -0400
In-Reply-To: <7e920337fab72cc388b20ac95c2e198b84145483.1498733815.git.arvind.yadav.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Thu, 29 Jun 2017 16:31:26 +0530

> attribute_groups are not supposed to change at runtime. All functions
> working with attribute_groups provided by <linux/device.h> work with const
> attribute_group. So mark the non-const structs as const.
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>    9968	   3168	     16	  13152	   3360	net/core/net-sysfs.o
> 
> File size After adding 'const':
>    text	   data	    bss	    dec	    hex	filename
>   10160	   2976	     16	  13152	   3360	net/core/net-sysfs.o
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
