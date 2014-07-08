From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Tue, 8 Jul 2014 07:49:19 +0200
Message-ID: <20140708054919.GA3977@localhost.localdomain>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-2-git-send-email-willemb@google.com>
 <20140705201851.GE3869@localhost.localdomain>
 <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com>
 <20140707184700.GA1610@localhost.localdomain>
 <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com>
 <53BAF8AC.6010907@cavium.com>
 <20140707201817.GA10683@localhost.localdomain>
 <53BB0C69.6000304@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chad Reese <kreese@caviumnetworks.com>,
	David Daney <david.daney@cavium.com>
To: Chad Reese <kreese@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:48308 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbaGHFtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 01:49:43 -0400
Received: by mail-wi0-f171.google.com with SMTP id n15so300503wiw.16
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 22:49:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53BB0C69.6000304@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2014 at 02:08:57PM -0700, Chad Reese wrote:
> 
> No, it was 1ns. Who would go through all this effort if all you
> wanted was 1us?  Our requirement was within 20ns, but me managed to
> get 1ns with a lab setup. We had to be careful that the scope probes
> used in the measurement were the same length.

Well, in a lab, carefully compensating for phy delays, etc, etc,
achieving 1ns is one thing. As a general statement, telling the
public, "our PTP hardware synchronizes to within one nanosecond",
is quite another thing.

Thanks,
Richard
