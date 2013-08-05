From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2 1/8] net: introduce generic union inet_addr
Date: Mon, 05 Aug 2013 11:09:52 +0800
Message-ID: <1375672192.32485.6.camel@cr0>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com>
	 <1375427674-21735-2-git-send-email-amwang@redhat.com>
	 <20130802.145041.845804796107623114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com, joe@perches.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754434Ab3HEDKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Aug 2013 23:10:20 -0400
In-Reply-To: <20130802.145041.845804796107623114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-02 at 14:50 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Fri,  2 Aug 2013 15:14:27 +0800
> 
> > From: Cong Wang <amwang@redhat.com>
> > 
> > Introduce a generic IP address type, union inet_addr, so that
> > subsystems don't have to use their own definitions. Because
> > netpoll already defines union inet_addr, just move it to global.
> > Some of the helper functions will be used by VXLAN IPv6 code too.
> > 
> > This patch also reuses the "%pIS" specifier, to make it accept
> > union inet_addr instead of struct sockaddr.
> > 
> > Cc: Daniel Borkmann <dborkman@redhat.com>
> > Cc: Joe Perches <joe@perches.com>
> > Cc: linux-kernel@vger.kernel.org
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Changing %pIS to %pIA is pure churn, and of zero value that I can see.

'S' in %pIS is for Sockaddr, since this patch makes it accept union
inet_addr instead of struct sockaddr, I don't think 'S' is meaningful
any more.

> 
> Every time I review this patch set I discover some new thing that I'm
> very disappointed with.

The "%pIS" change exists in v1, I don't know why you think it is new in
v2. Also, if you can point all what you dislike at one time, it would
save time for both of us, I prefer to fix them all in one update.

> 
> You're going to have to stop being so ambitious, and start very small.
> 
> Maybe one tiny patch at a time if needed.

Ok, I will split the %pIS change from this patch.

Thanks!
