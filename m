From: "Kelly Burkhart" <kelly.burkhart@gmail.com>
Subject: Re: high latency with TCP connections
Date: Thu, 31 Aug 2006 13:22:09 -0500
Message-ID: <fa1e4ce70608311122n6555b7c3n1ecec9ed3adc46c2@mail.gmail.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru>
	 <20060830102727.11e11453@localhost.localdomain>
	 <20060830.143955.55510936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:10900 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932410AbWHaSWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 14:22:11 -0400
Received: by ug-out-1314.google.com with SMTP id m3so636143ugc
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 11:22:10 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060830.143955.55510936.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/30/06, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> > Expecting any performance with one byte write's is silly.
>
> This is absolutely true.  TCP_NODELAY can only save you when you are
> sending a small amount of data "in aggregate", such as in an SSH or
> telnet session, whereas in the case being shown here a large amount of
> data is being sent in small chunks which will always get bad
> performance.


The word performance in this list seems to always mean 'throughput'.
It seems though that there could be some knob to tweak for those of us
who don't care so much about throughput but care a great deal about
latency.

-K
