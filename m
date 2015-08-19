From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 07/13] ipv6: drop metadata dst in
 ip6_route_input
Date: Wed, 19 Aug 2015 18:41:48 +0200
Message-ID: <20150819164148.GG3635@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <da9ffa03a9260042f5f325b1e7d56ded32d846b5.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Wei-Chun Chao <weichunc@plumgrid.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37740 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbbHSQlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:41:50 -0400
Received: by wibhh20 with SMTP id hh20so13588178wib.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 09:41:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <da9ffa03a9260042f5f325b1e7d56ded32d846b5.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:09pm, Jiri Benc wrote:
> The fix in commit 48fb6b554501 is incomplete, as now ip6_route_input can be
> called with non-NULL dst if it's a metadata dst and the reference is leaked.
> Drop the reference.
> 
> Fixes: 48fb6b554501 ("ipv6: fix crash over flow-based vxlan device")
> Fixes: ee122c79d422 ("vxlan: Flow based tunneling")
> CC: Wei-Chun Chao <weichunc@plumgrid.com>
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
