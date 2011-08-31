From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Fail "ip netns add" on existing network
 namespaces.
Date: Wed, 31 Aug 2011 11:05:15 -0700
Message-ID: <20110831110515.4ecd349e@nehalam.ftrdhcpuser.net>
References: <m1hb6nkqyx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40112 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932208Ab1HaSFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 14:05:05 -0400
In-Reply-To: <m1hb6nkqyx.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jul 2011 17:29:41 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> 
> Use O_EXCL so that we only create and mount a new network namespace
> if there is no chance an existing network namespace is present.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Both setns patches applied
