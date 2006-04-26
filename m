From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 12:30:13 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143AE6C@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: kelly@au1.ibm.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:24337 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S964851AbWDZTa0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 15:30:26 -0400
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> 
> I personally think allowing sockets to trump firewall rules
> is an acceptable relaxation of the rules in order to simplify
> the implementation.

I agree.  I have never seen a set of netfilter rules that
would block arbitrary packets *within* an established connection.

Technically you can create such rules, but every single set
of rules actually deployed that I have ever seen started with
a rule to pass all packets for established connections, and
then proceeded to control which connections could be initiated
or accepted.



