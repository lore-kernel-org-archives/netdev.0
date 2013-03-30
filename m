From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] include/linux: printk is needed in filter.h when
 CONFIG_BPF_JIT is defined
Date: Fri, 29 Mar 2013 23:32:20 -0400 (EDT)
Message-ID: <20130329.233220.2002219172165994260.davem@davemloft.net>
References: <5154ED65.5090607@asianux.com>
	<20130329.153447.426374969178935845.davem@davemloft.net>
	<515657BF.7010101@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dborkman@redhat.com, wad@chromium.org,
	eparis@redhat.com, netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757606Ab3C3DcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 23:32:22 -0400
In-Reply-To: <515657BF.7010101@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Sat, 30 Mar 2013 11:10:55 +0800

> On 2013年03月30日 03:34, David Miller wrote:
>> From: Chen Gang <gang.chen@asianux.com>
>> Date: Fri, 29 Mar 2013 09:24:53 +0800
>> 
>>> > 
>>> >   for make V=1 EXTRA_CFLAGS=-W ARCH=arm allmodconfig
>>> >     printk is need when CONFIG_BPF_JIT is defined
>>> >     or it will report pr_err and print_hex_dump are implicit declaration
>>> > 
>>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> There are no references to pr_err nor print_hex_dump in this
>> filter.h header file.
> 
>   maybe we see the different tree.
>   I find it in next-20130328.

When you submit patches, always mention explicitly what tree you
want the patch applied to.

In this case, this appropriate tree to be "net-next" since that
is the tree where the problem actually exists.

Patch applied, thanks.
