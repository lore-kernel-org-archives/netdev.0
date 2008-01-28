From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix race that causes invalid statistics
Date: Mon, 28 Jan 2008 15:59:03 -0800
Message-ID: <23624.1201564743@death>
References: <20080128233825.GA21912@gospo.usersys.redhat.com>
Cc: netdev@vger.kernel.org, csnook@redhat.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:33903 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbYA1X7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 18:59:08 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0SNx66e017114
	for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 18:59:06 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0SNx5b7088286
	for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 16:59:05 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0SNx5XZ029177
	for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 16:59:05 -0700
In-reply-to: <20080128233825.GA21912@gospo.usersys.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>+	memcpy(stats,&local_stats,sizeof(net_device_stats));

	FYI, this generates a compiler error (missing the word "struct"
in here).  Other than not compiling, the patch seems reasonable.  I'll
fix it up and include it in the series I'll post tomorrow or so.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
