From: David Miller <davem@davemloft.net>
Subject: Re: [Security] [SECURITY] DECnet: need to validate user data and
 access data?
Date: Tue, 22 Mar 2011 02:21:01 -0700 (PDT)
Message-ID: <20110322.022101.45900222.davem@davemloft.net>
References: <1300750901.1813.15.camel@dan>
	<AANLkTinbj295sZvXrQm6uhH9+DbAbY1AZU7Eo5_dC6HP@mail.gmail.com>
	<1300785230.2558.6.camel@dolmen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eugeneteo@kernel.org, drosenberg@vsecurity.com,
	netdev@vger.kernel.org, security@kernel.org,
	linux-decnet-user@lists.sourceforge.net
To: swhiteho@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39138
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752270Ab1CVJUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 05:20:23 -0400
In-Reply-To: <1300785230.2558.6.camel@dolmen>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Whitehouse <swhiteho@redhat.com>
Date: Tue, 22 Mar 2011 09:13:50 +0000

> These functions are used in relation to conninit messages which, on the
> incoming side are checked in dn_nsp_in.c:dn_find_listener() via the
> calls to dn_check_idf() so that we should never queue an incorrectly
> formatted message to the socket. The intent was that all messages should
> be checked as early as possible on entry to the code so that we can then
> rely on their content later on without needing to check again.

Ok, so we should be find here.

Thanks for the explanation Steven.
