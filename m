From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] vxlan: preserve type of dst_port parm for
 encap_bypass_if_local()
Date: Thu, 19 Jan 2017 19:16:00 +0100
Message-ID: <20170119191600.5d86c35b@griffin>
References: <1484771097-5692-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48706 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754016AbdASScu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 13:32:50 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DA7823B70B
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 18:16:03 +0000 (UTC)
In-Reply-To: <1484771097-5692-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jan 2017 15:24:57 -0500, Lance Richardson wrote:
> Eliminate sparse warning by maintaining type of dst_port
> as __be16.

Fixes: fee1fad7c73d ("vxlan: simplify RTF_LOCAL handling.")

> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Acked-by: Jiri Benc <jbenc@redhat.com>
