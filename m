From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/4] igb: enable internal PPS for the i210.
Date: Wed, 19 Nov 2014 21:26:04 +0100
Message-ID: <20141119202604.GA22213@localhost.localdomain>
References: <cover.1416265321.git.richardcochran@gmail.com>
 <e5b4ef7c56119e2d86e42f5680b1b82c9ec1a38e.1416265321.git.richardcochran@gmail.com>
 <20141119063724.GB4109@localhost.localdomain>
 <1416425553.15933.32.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:52140 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755776AbaKSU0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 15:26:10 -0500
Received: by mail-wg0-f53.google.com with SMTP id l18so1822819wgh.12
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 12:26:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416425553.15933.32.camel@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 07:32:33PM +0000, Keller, Jacob E wrote:
> Good catch :)

(Well, my X session suddenly disappeared, and a kernel oops appeared in
the console... hard to overlook ;^)
 
> Did you see my concern about the reset path needing to fully restore the
> state since it is called after a hardware MAC reset which has cleared
> all these registers?

Yes, and that bit I copied from the first series a year ago. I don't
remember why, but IIRC that was necessary to let the SDP stuff work at
all. Maybe the reset function was called under different circumstances
back then. I'll take another look.

I find it a bit weird that the auxiliary functions don't work when the
interface or the link is down.

Thanks,
Richard
