From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: bonding: fix slave speed reporting in bond_miimon_commit
Date: Thu, 20 Jun 2013 15:42:48 +0200
Message-ID: <20130620134247.GA1157@redhat.com>
References: <1371731653-13568-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	davem@davemloft.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756845Ab3FTNnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 09:43:50 -0400
Content-Disposition: inline
In-Reply-To: <1371731653-13568-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 02:34:13PM +0200, nikolay@redhat.com wrote:
>From: Nikolay Aleksandrov <nikolay@redhat.com>
>
>When we have BOND_LINK_UP the speed is reported unconditionally with %u
>format although it can be SPEED_UNKNOWN (-1). After this patch it returns
>0 in that case in an attempt to keep the existing scripts happy.
>One line is intenionally left 81 chars because it gets ugly if broken.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>

Acked-by: Veaceslav Falico <vfalico@redhat.com>
