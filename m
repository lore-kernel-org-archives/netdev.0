From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 4/5] vxlan: add scope_id support for ll addr
Date: Sun, 21 Apr 2013 21:47:13 +0800
Message-ID: <1366552033.23100.16.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-5-git-send-email-amwang@redhat.com>
	 <OFA1761298.DF396ECD-ON85257B52.003AE2CA-85257B52.003DBDAB@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753430Ab3DUNr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 09:47:26 -0400
In-Reply-To: <OFA1761298.DF396ECD-ON85257B52.003AE2CA-85257B52.003DBDAB@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 07:14 -0400, David Stevens wrote:
> 
>         As I commented before, you're obscuring the types here,
> which makes it less readable. "va_sin6" ought to be a sockaddr_in6,
> not a sin6_addr, and the scope id ought to then be 
> "va_sin6.sin6_scope_id",
> without any other #define necessary for it.

So finally you want something like:

vxlan->default_dst.remote_ip.va_sin.sin_addr.s_addr

and

vxlan->default_dst.remote_ip.va_sin6.sin6_addr

Enjoy the readable code! :)

Again, I don't like this at all from the beginning! I just want to make
David happy. v5 is on the way...

For the record, please don't blame me if you think the code is ugly. :)
