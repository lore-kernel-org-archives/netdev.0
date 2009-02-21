From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [BUG PATCH NET-NEXT-2.6] kernel panic in dev_hard_start_xmit:
	remove faulty software TX time stamping
Date: Sat, 21 Feb 2009 02:37:33 -0800
Message-ID: <9929d2390902210237t22ec897akc197a50760be6525@mail.gmail.com>
References: <1235208488.22598.40.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:23662 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbZBUKhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 05:37:34 -0500
Received: by yx-out-2324.google.com with SMTP id 8so509765yxm.1
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2009 02:37:33 -0800 (PST)
In-Reply-To: <1235208488.22598.40.camel@pohly-MOBL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 21, 2009 at 1:28 AM, Patrick Ohly <patrick.ohly@intel.com> wrote:
> The current implementation of the TX software time stamping fallback is
> faulty because it accesses the skb after ndo_start_xmit() returns
> successfully. This patch removes the fallback, which fixes kernel panics
> seen during stress tests. Hardware time stamping is not affected by this
> removal.
>
> Signed-Off: Patrick Ohly <patrick.ohly@intel.com>
> Signed-Off: Emil Tantilov <emil.s.tantilov@intel.com>
>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
