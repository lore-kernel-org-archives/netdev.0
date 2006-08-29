From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/6] NetLabel: correctly initialize the NetLabel fields
Date: Tue, 29 Aug 2006 13:01:20 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608291259490.29142@d.namei>
References: <20060829144251.452774000@hp.com> <20060829144444.202106000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:14520 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S965141AbWH2RBW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 13:01:22 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20060829144444.202106000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Aug 2006, paul.moore@hp.com wrote:

> Fix a problem where the NetLabel specific fields of the sk_security_struct
> structure were not being initialized early enough in some cases.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Regardless of the mapped ipv6 socket issue, I think these should be 
applied as fixes in their own right.  The mapped ipv6 socket stuff can be 
done separately if required.


Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
