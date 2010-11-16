From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: network device reference leak with net-next
Date: Tue, 16 Nov 2010 20:21:40 +0100
Message-ID: <AANLkTi=nCmL+09CAnTHn6Yn8dcrvkRxxnAgUNHPQbUeM@mail.gmail.com>
References: <20101115105646.0cc823ce@nehalam> <1289847840.2607.120.camel@edumazet-laptop>
 <20101115111024.3b3377be@nehalam> <4CE1BFCE.70105@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	brian.haley@hp.com, maze@google.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:56931 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab0KPTWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 14:22:04 -0500
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id oAGJM2Ng020831
	for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 11:22:02 -0800
Received: from gwb10 (gwb10.prod.google.com [10.200.2.10])
	by kpbe16.cbf.corp.google.com with ESMTP id oAGJM1Yi024364
	for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 11:22:01 -0800
Received: by gwb10 with SMTP id 10so649101gwb.29
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 11:22:01 -0800 (PST)
In-Reply-To: <4CE1BFCE.70105@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 16, 2010 at 12:18 AM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> Quick glance looks like an in6_ifa_put is missed?

Oops. Sorry about that.

I'm testing your fix, it seems to work so far.
