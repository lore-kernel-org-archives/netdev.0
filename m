From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Re: [RFC] TCP illinois max rtt aging
Date: Mon, 3 Dec 2007 17:23:35 -0800
Message-ID: <aa7d2c6d0712031723t314da471n8f033e8d1b523e1a@mail.gmail.com>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com>
	 <001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu>
	 <20071128154725.29af2852@freepuppy.rosehill>
	 <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com>
	 <474E0B33.2060108@linux-foundation.org>
	 <001b01c83248$604f4120$20edc360$@edu>
	 <20071203145207.40e4ac57@freepuppy.rosehill>
	 <aa7d2c6d0712031506i73df4410p9ab8b1a60bc2ad2d@mail.gmail.com>
	 <002f01c83608$8a2fb600$9e8f2200$@edu>
	 <20071203163217.27e4df3f@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shaoliu@princeton.edu, "David S. Miller" <davem@davemloft.net>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Douglas Leith" <doug.leith@nuim.ie>,
	"Robert Shorten" <robert.shorten@nuim.ie>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:16426 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbXLDBXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 20:23:37 -0500
Received: by py-out-1112.google.com with SMTP id u77so6853534pyb
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2007 17:23:36 -0800 (PST)
In-Reply-To: <20071203163217.27e4df3f@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

On 03/12/2007, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Mon, 3 Dec 2007 15:59:23 -0800
> "Shao Liu" <shaoliu@Princeton.EDU> wrote:
> > And also a question, why the samples when SACK is active are outliers?
>
> Any sample with SACK is going to mean a loss or reordering has occurred.
> So shouldn't the SACK values be useful, but RTT values from retransmits
> are not useful.

When SACK is active, the per-packet processing becomes more involved,
tracking the list of lost/SACKed packets.  This causes a CPU spike
just after a loss, which increases the RTTs, at least in my
experience.  This is a separate issue from the fact that it is hard to
get RTT measurements from lost/retransmitted packets themselves.

Cheers,
Lachlan

-- 
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/~lachlan
