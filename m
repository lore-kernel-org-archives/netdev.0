From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] bridge: add tracepoint in br_fdb_update
Date: Thu, 31 Aug 2017 23:50:26 +0200
Message-ID: <20170831235026.6377bf86@redhat.com>
References: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
        <20170831.114325.2027598728601121750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46248 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750908AbdHaVuc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 17:50:32 -0400
In-Reply-To: <20170831.114325.2027598728601121750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Aug 2017 11:43:25 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Wed, 30 Aug 2017 22:18:13 -0700
> 
> > From: Roopa Prabhu <roopa@cumulusnetworks.com>
> > 
> > This extends bridge fdb table tracepoints to also cover
> > learned fdb entries in the br_fdb_update path. Note that
> > unlike other tracepoints I have moved this to when the fdb
> > is modified because this is in the datapath and can generate
> > a lot of noise in the trace output. br_fdb_update is also called
> > from added_by_user context in the NTF_USE case which is already
> > traced ..hence the !added_by_user check.
> > 
> > Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>  
> 
> Applied.
> 
> Let's use dev->name for now and if the tooling can eventually
> do transparent ifindex->name then we can consider redoing
> a bunch of networking tracepoints.

I agree! :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
