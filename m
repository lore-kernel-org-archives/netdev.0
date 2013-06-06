From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v3 1/3] igmp: fix return value of some functions
Date: Thu, 6 Jun 2013 16:16:14 -0400
Message-ID: <OFF0DFA533.AF670FB8-ON85257B82.006E0B5C-85257B82.006F58EF@us.ibm.com>
References: <1370485211-11498-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:33674 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656Ab3FFU37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 16:29:59 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 6 Jun 2013 14:29:58 -0600
In-Reply-To: <1370485211-11498-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Cong Wang <amwang@redhat.com>

> 
> There are some places casting the return value to void, actually
> they can respect the return value.

        This changes the user-visible errno returns, adding new,
undocumented errno returns for a POSIX-defined API.

NACK.

                                                +-DLS
