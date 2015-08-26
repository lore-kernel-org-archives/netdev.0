From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] route: put lwstate before freeing dst to avoid use
 after free
Date: Wed, 26 Aug 2015 12:35:31 +0200
Message-ID: <20150826123531.4f27f124@griffin>
References: <1440527114-12746-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, roopa@cumulusnetworks.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754105AbbHZKfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 06:35:38 -0400
In-Reply-To: <1440527114-12746-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2015 14:25:14 -0400, Sasha Levin wrote:
> Commit 61adedf3 ("route: move lwtunnel state to dst_entry") is trying to
> release lwstate after getting rid of dst, which causes a use-after-free
> trying to access dst->lwstate.
> 
> Fixes: 61adedf3 ("route: move lwtunnel state to dst_entry")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Already fixed by e252b3d1a174 in net-next.

 Jiri

-- 
Jiri Benc
