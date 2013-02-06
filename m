From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] openvswitch: adjust skb_gso_segment() for rx
 path
Date: Wed, 06 Feb 2013 10:36:22 +0800
Message-ID: <1360118182.23727.1.camel@cr0>
References: <1359535089-18348-1-git-send-email-amwang@redhat.com>
	 <CAEP_g=-pdossS=kAVzQMuvTnKU-Sg9PvskiocqcxdsBDtbvdCw@mail.gmail.com>
	 <1359596906.29117.9.camel@cr0>
	 <CAEP_g=9JqFi7apps-aDqxuGck-hYSvaUT6pzXR-gDkAvLovS8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754330Ab3BFCga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 21:36:30 -0500
In-Reply-To: <CAEP_g=9JqFi7apps-aDqxuGck-hYSvaUT6pzXR-gDkAvLovS8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-31 at 17:09 -0800, Jesse Gross wrote:
> I think this is a different problem, unrelated to the checksum issue.
> Can you test this patch:
> http://git.kernel.org/?p=linux/kernel/git/jesse/openvswitch.git;a=commit;h=d9d59089c43fc33eb403cbb928e56c131f191dd5
> 
> I believe it should fix the problem, although there are still a few
> lingering reports that I'm trying to track down. 

Our QE tested your patch and my updated patch on 2.6.32, no panic any
more.

I will post my updated patch now.

Thanks!
