From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 0/7] net: introduce generic type and helpers
 for IP address
Date: Tue, 23 Jul 2013 10:00:23 +0800
Message-ID: <1374544823.24933.1.camel@cr0>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374525857.2061.57.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750872Ab3GWCAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 22:00:32 -0400
In-Reply-To: <1374525857.2061.57.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 13:44 -0700, Joe Perches wrote:
> 
> I see no reason why vsprint's support for
> "struct sockaddr *" %pIS should be removed.
> 
> %pIS and %pIA can both exist.
> 
> 

Because there is no need to keep both of them, struct sockaddr can be
safely converted to union inet_addr.
