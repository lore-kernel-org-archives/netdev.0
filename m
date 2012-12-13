From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next:master 14/17] net/bridge/br_mdb.c:330
 br_mdb_add_group() error: potential null dereference 'mp'.
 (br_multicast_new_group returns null)
Date: Thu, 13 Dec 2012 15:15:05 +0800
Message-ID: <1355382905.14802.34.camel@cr0>
References: <50c8d94d.VSxb5ulWJHo9Ahhi%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786Ab2LMHPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 02:15:17 -0500
In-Reply-To: <50c8d94d.VSxb5ulWJHo9Ahhi%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-13 at 03:21 +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   520dfe3a3645257bf83660f672c47f8558f3d4c4
> commit: cfd567543590f71ca0af397437e2554f9756d750 [14/17] bridge: add support of adding and deleting mdb entries
> 
> 
> smatch warnings:
> 
> + net/bridge/br_mdb.c:330 br_mdb_add_group() error: potential null dereference 'mp'.  (br_multicast_new_group returns null)

br_multicast_new_group() seems impossible to return NULL, it either
returns a valid pointer (non-NULL) or some errno pointer.

OTOH, br_multicast_add_group() doesn't check for NULL either.
