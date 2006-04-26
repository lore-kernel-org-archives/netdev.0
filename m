From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 15:46:58 -0400
Message-ID: <444FCE32.2010207@garzik.org>
References: <54AD0F12E08D1541B826BE97C98F99F143AE6C@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:28816 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932318AbWDZTrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 15:47:06 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143AE6C@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Caitlin Bestler wrote:
> David S. Miller wrote:
> 
>> I personally think allowing sockets to trump firewall rules
>> is an acceptable relaxation of the rules in order to simplify
>> the implementation.
> 
> I agree.  I have never seen a set of netfilter rules that
> would block arbitrary packets *within* an established connection.
> 
> Technically you can create such rules, but every single set
> of rules actually deployed that I have ever seen started with
> a rule to pass all packets for established connections, and
> then proceeded to control which connections could be initiated
> or accepted.

Oh, there are plenty of examples of filtering within an established 
connection:  input rules.  I've seen "drop all packets from <these> IPs"
type rules frequently.  Victims of DoS use those kinds of rules to stop 
packets as early as possible.

	Jeff


