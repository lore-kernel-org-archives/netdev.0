From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Null pointer dereference in bonding driver, kernel 2.6.24
Date: Thu, 31 Jan 2008 14:55:29 -0800
Message-ID: <3489.1201820129@death>
References: <47A24D65.2000001@redhat.com>
Cc: Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:59029 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbYAaWzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 17:55:45 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0VMteMv016995
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 17:55:40 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0VMtdlC201614
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 15:55:39 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0VMtd4C002786
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 15:55:39 -0700
In-reply-to: <47A24D65.2000001@redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Ebbert <cebbert@redhat.com> wrote:

>In bond_main.c:
>
>int bond_create(char *name, struct bond_params *params, struct bonding **newbond)
>{
>...
>        /* Check to see if the bond already exists. */
>        list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
>                if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
>                        printk(KERN_ERR DRV_NAME
>                               ": cannot add bond %s; it already exists\n",
>
>
>If 'name' is null we get a null dereference in strnicmp()
>
>The code was added in 2.6.24.

	This is already fixed in netdev-2.6#upstream.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
