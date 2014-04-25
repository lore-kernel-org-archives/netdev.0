From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2 3/5] net: filter: get rid of sock_fprog_kern
Date: Fri, 25 Apr 2014 09:58:31 +0200
Message-ID: <535A15A7.7080306@redhat.com>
References: <1398321927-8845-1-git-send-email-dborkman@redhat.com> <1398321927-8845-4-git-send-email-dborkman@redhat.com> <20140424.160237.1682834218902091375.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418AbaDYH6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2014 03:58:42 -0400
In-Reply-To: <20140424.160237.1682834218902091375.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2014 10:02 PM, David Miller wrote:
...
> It's so that we can always have the correct type for the pointers, and
> we can show cleanly (without lots of ugly casts) to sparse that whether
> we expect a pointer to be a user or a kernel one.

Understood, I'll take the time to go the other way around and try to
convert sk_unattached_filter_create() API to use struct sock_fprog_kern
instead as this is only for in-kernel users.
