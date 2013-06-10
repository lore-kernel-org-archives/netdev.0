From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: add missing
 /proc/sys/net/ipv6/ping_group_range
Date: Mon, 10 Jun 2013 11:02:02 +0800
Message-ID: <1370833322.11543.1.camel@cr0>
References: <1370685275-22059-1-git-send-email-amwang@redhat.com>
	 <CAKD1Yr1JcL22bSGyvNQrUj4iPNxH3NS+re7jXeBEuvCTJf-Hjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab3FJDCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 23:02:11 -0400
In-Reply-To: <CAKD1Yr1JcL22bSGyvNQrUj4iPNxH3NS+re7jXeBEuvCTJf-Hjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-09 at 18:42 +0900, Lorenzo Colitti wrote:
> On Sat, Jun 8, 2013 at 6:54 PM, Cong Wang <amwang@redhat.com> wrote:
> > commit 6d0bfe22611602f366 (net: ipv6: Add IPv6 support to the ping socket.)
> > adds IPv6 ping socket support, but forgot to create
> > /proc/sys/net/ipv6/ping_group_range, therefore it wrongly shares
> > /proc/sys/net/ipv4/ping_group_range with IPv4.
> 
> As you said, I'm not sure that sharing the sysctl file with IPv4 is a
> problem. Is it useful to support different permissions for IPv4 ping
> versus IPv6 ping? I would imagine that if an admin wants certain
> groups to be able to run ping, those groups would be the same for IPv4
> ping and IPv6 ping. But I'm not the authority here. Maybe David has an
> opinion?
> 

I think we can just ignore the patch for now, we can add it if someone
requests for it in future.
