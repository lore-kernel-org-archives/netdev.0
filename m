From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: sctp_transport_destroy{,_rcu}: fix potential
 pointer corruption
Date: Fri, 09 Aug 2013 12:33:07 +0200
Message-ID: <5204C563.5030808@redhat.com>
References: <1376042849-19732-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18388 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966522Ab3HIKdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 06:33:12 -0400
In-Reply-To: <1376042849-19732-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2013 12:07 PM, Daniel Borkmann wrote:
> Probably this one is quite unlikely to be triggered, but it's more safe
> to hold a pointer to asoc and packet (instead of dereferencing) and access
> both though this after we have called sctp_transport_destroy_rcu() where
> the transport is being kfree()'d. Introduced by commit 8c98653f ("sctp:
> sctp_close: fix release of bindings for deferred call_rcu's").
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Please ignore this, will send an updated v2 in a moment.
