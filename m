From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next 1/2] ip_gre: increase inner ip header ID during
 segmentation
Date: Sat, 23 Mar 2013 11:25:05 +0800
Message-ID: <1364009105.10472.2.camel@cr0>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
	 <1363948292-9902-1-git-send-email-amwang@redhat.com>
	 <CALnjE+q=v4iu7kQod103P-gqCf5YRmJOKeA4-ev9LA_diaVdYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17656 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422808Ab3CWDZV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 23:25:21 -0400
In-Reply-To: <CALnjE+q=v4iu7kQod103P-gqCf5YRmJOKeA4-ev9LA_diaVdYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 10:12 -0700, Pravin Shelar wrote:
> On Fri, Mar 22, 2013 at 3:31 AM, Cong Wang <amwang@redhat.com> wrote:
> > From: Cong Wang <amwang@redhat.com>
> >
> > According to the previous discussion [1] on netdev list, DaveM insists
> > we should increase the IP header ID for each segmented packets.
> > This patch fixes it.
> >
> 
> Outer IP header ids are incremented in inet_gso_segment for GRE. So it
> is already done. In any case I don't think we should increment
> IP-Identification in GRE handler, This is layering violation.
> This breaks GRE with IPV6 payload.

I knew, $subject mentions this increases the *inner* IP header ID, not
outer one.

But you are probably right that we should check for IPv4, I will send
patch to fix it.

Thanks.
