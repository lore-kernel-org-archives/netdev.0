From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [ovs-dev] [PATCH net] openvswitch: Consistently include VLAN header in flow and port stats.
Date: Wed, 31 Dec 2014 16:45:47 -0200
Message-ID: <236677479.1E9A6SMX1Y@t520.home>
References: <1420044346-27957-1-git-send-email-blp@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ben Pfaff <blp@nicira.com>, netdev@vger.kernel.org,
	Motonori Shindo <mshindo@vmware.com>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:58364 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbaLaSpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 13:45:51 -0500
Received: from homiemail-a23.g.dreamhost.com (sub3.mail.dreamhost.com [69.163.253.7])
	by hapkido.dreamhost.com (Postfix) with ESMTP id A25FF83B91
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 10:45:51 -0800 (PST)
In-Reply-To: <1420044346-27957-1-git-send-email-blp@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, December 31, 2014 08:45:46 AM Ben Pfaff wrote:
> Until now, when VLAN acceleration was in use, the bytes of the VLAN header
> were not included in port or flow byte counters.  They were however
> included when VLAN acceleration was not used.  This commit corrects the
> inconsistency, by always including the VLAN header in byte counters.
> 
> Previous discussion at
> http://openvswitch.org/pipermail/dev/2014-December/049521.html
> 
> Reported-by: Motonori Shindo <mshindo@vmware.com>
> Signed-off-by: Ben Pfaff <blp@nicira.com>
> ---
>  net/openvswitch/flow.c  | 5 +++--
>  net/openvswitch/vport.c | 2 +-
>  2 files changed, 4 insertions(+), 3 deletions(-)

Looks good to me.
Reviewed-by: Flavio Leitner <fbl@sysclose.org>
