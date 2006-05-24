From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH] bridge: need to ref count the LLC sap
Date: Tue, 23 May 2006 21:36:38 -0300
Message-ID: <39e6f6c70605231736ya62e553s671ae06d8d7d9533@mail.gmail.com>
References: <20060523151035.43e7e4f6@localhost.localdomain>
	 <20060523.152103.97293770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:16595 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932274AbWEXAgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 20:36:39 -0400
Received: by ug-out-1314.google.com with SMTP id a2so1684749ugf
        for <netdev@vger.kernel.org>; Tue, 23 May 2006 17:36:38 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060523.152103.97293770.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/23/06, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Subject: [PATCH] bridge: need to ref count the LLC sap
> Date: Tue, 23 May 2006 15:10:35 -0700
>
> > Bridge will OOPS on removal if other application has the SAP open.
> > The bridge SAP might be shared with other usages, so need
> > to do reference counting on module removal rather than explicit
> > close/delete.
> >
> > Since packet might arrive after or during removal, need to clear
> > the receive function handle, so LLC only hands it to user (if any).
> >
> > This should go in 2.616.stable and 2.6.17.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>
> Applied, thanks a lot.
>
> Please submit to -stable.

Thanks Stephen for the patches, Dave for the quick merge, I'm still
out in la la work related land, hope to be back to fun work soon :-)

- Arnaldo
