From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net] openvswitch: Remove incorrect WARN_ONCE().
Date: Tue, 2 Aug 2016 14:12:01 -0700
Message-ID: <CAPWQB7FyNnDh8+jc1n6Djs8UFLC4=xL=xU8J94rdqF8TzcuCkg@mail.gmail.com>
References: <1470105367-46582-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:52985 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754003AbcHBVNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 17:13:52 -0400
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id 66DF047B1AD
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2016 23:13:27 +0200 (CEST)
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id B97F441C07D
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2016 23:12:24 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id 2pzJOnj4WfrG for <netdev@vger.kernel.org>;
	Tue,  2 Aug 2016 23:12:23 +0200 (CEST)
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	(Authenticated sender: joe@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 1473041C08A
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2016 23:12:22 +0200 (CEST)
Received: by mail-oi0-f42.google.com with SMTP id w18so254904254oiw.3
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 14:12:22 -0700 (PDT)
In-Reply-To: <1470105367-46582-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 August 2016 at 19:36, Jarno Rajahalme <jarno@ovn.org> wrote:
> ovs_ct_find_existing() issues a warning if an existing conntrack entry
> classified as IP_CT_NEW is found, with the premise that this should
> not happen.  However, a newly confirmed, non-expected conntrack entry
> remains IP_CT_NEW as long as no reply direction traffic is seen.  This
> has resulted into somewhat confusing kernel log messages.  This patch
> removes this check and warning.
>
> Fixes: 289f2253 ("openvswitch: Find existing conntrack entry after upcall.")
> Suggested-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Thanks for the patch, this will remove a false positive kernel log
from a common case in OVS with stateful processing.

Acked-by: Joe Stringer <joe@ovn.org>
