From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/16] net: Add a network namespace parameter to struct
 sock
Date: Wed, 12 Sep 2007 02:58:50 -0700 (PDT)
Message-ID: <20070912.025850.28798873.davem@davemloft.net>
References: <m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
	<m1wsv0vony.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:35491
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758415AbXILJ6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 05:58:53 -0400
In-Reply-To: <m1wsv0vony.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:21:37 -0600

> 
> Sockets need to get a reference to their network namespace,
> or possibly a simple hold if someone registers on the network
> namespace notifier and will free the sockets when the namespace
> is going to be destroyed.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks.
