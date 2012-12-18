From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 04/11] bridge: Cache vlan in the cb for faster egress
 lookup.
Date: Tue, 18 Dec 2012 09:04:48 -0800
Message-ID: <20121218090448.69c21daa@nehalam.linuxnetplumber.net>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
	<1355342477-4971-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	john.r.fastabend@intel.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50875 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119Ab2LRRGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 12:06:49 -0500
In-Reply-To: <1355342477-4971-5-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 15:01:10 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> On input, cache the pointer to the bridge vlan info, so that
> on egress, we have can simply look at the port bitmap instead
> of traversing a vlan list.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

This isn't going to be safe. Once packet is passed up, the cb[]
can get overwritten by other things.
