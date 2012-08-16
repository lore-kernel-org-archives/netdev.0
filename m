From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sctp: fix bogus if statement in sctp_auth_recv_cid()
Date: Thu, 16 Aug 2012 13:37:04 -0700 (PDT)
Message-ID: <20120816.133704.75563710683878972.davem@davemloft.net>
References: <20120816131618.GA23279@elgon.mountain>
	<87txw266hk.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, vyasevich@gmail.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757324Ab2HPUhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 16:37:05 -0400
In-Reply-To: <87txw266hk.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 16 Aug 2012 11:23:35 -0700

> Dan Carpenter <dan.carpenter@oracle.com> writes:
> 
>> There is an extra semi-colon here, so we always return 0 instead of
>> calling __sctp_auth_cid().
> 
> Doh.
> 
> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
