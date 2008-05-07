From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Tue, 06 May 2008 21:27:22 -0700 (PDT)
Message-ID: <20080506.212722.225900091.davem@davemloft.net>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	<20080425.000547.152086801.davem@davemloft.net>
	<d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752887AbYEGE11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 00:27:27 -0400
In-Reply-To: <d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Tue, 6 May 2008 20:57:46 -0700

> I fail to see how adding shinfo->in_flight to count how many
> outstanding clones are there can help accounting for how many
> "host_inflight" pkts. Part of the problems, as you've mentioned
> before, is that the driver may not always get a clone.

Sure but it will get one %99.9999 of the time.

With TCP, as long as that clone is alive the driver has it.  And the
counter only counts the clones.

Anyways, did you even test my patch and try to use it for your needs
or is this analysis purely from your inspection of it? :-/

