From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: openvswitch: Remove invalid comment
Date: Tue, 24 Nov 2015 17:18:16 -0500 (EST)
Message-ID: <20151124.171816.847333860489372651.davem@redhat.com>
References: <1448391113-18628-1-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: aconole@bytheb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196AbbKXWSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 17:18:17 -0500
In-Reply-To: <1448391113-18628-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>
Date: Tue, 24 Nov 2015 13:51:53 -0500

> During pre-upstream development, the openvswitch datapath used a custom
> hashtable to store vports that could fail on delete due to lack of
> memory. However, prior to upstream submission, this code was reworked to
> use an hlist based hastable with flexible-array based buckets. As such
> the failure condition was eliminated from the vport_del path, rendering
> this comment invalid.
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>

Applied, thanks.
