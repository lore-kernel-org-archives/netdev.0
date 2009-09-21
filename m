From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: "cfg80211: fix SME connect" breaks iwl3945
Date: Mon, 21 Sep 2009 21:14:06 +0200
Message-ID: <200909212114.06642.chunkeey@googlemail.com>
References: <20090921190150.GC23126@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	johannes@sipsolutions.net, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:60344 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301AbZIUTVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 15:21:12 -0400
In-Reply-To: <20090921190150.GC23126@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 21 September 2009 21:01:50 Jens Axboe wrote:
> Since the latest net pull that contains our above commit
> (bbac31f4c0339f6c51afbd0edfb4959df9b53fa9 in tree), my iwl3945 based x60
> laptop doesn't want to connect to my access point at all. Reverting this
> commit makes it work.
> 
> Let me know if you need more info.

Can you try "[PATCH] cfg80211: don't overwrite privacy setting" 
from [1]?

[1] http://marc.info/?l=linux-wireless&m=125323296617306&w=2

Regards,
	Chr
