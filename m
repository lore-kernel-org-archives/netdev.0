From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 12:36:01 -0400
Message-ID: <1494952561.3259.104.camel@redhat.com>
References: <1494788929.21774.1.camel@sandisk.com>
         <20170514.204404.1844909849561204299.davem@davemloft.net>
         <1494950224.3259.98.camel@redhat.com>
         <20170516.122923.869994491617365845.davem@davemloft.net>
         <20170516163041.GA5132@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170516163041.GA5132-jcswGhMUV9g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-16 at 18:30 +0200, Christoph Hellwig wrote:
> On Tue, May 16, 2017 at 12:29:23PM -0400, David Miller wrote:
> > 
> > I can't push back on people with silly coding style and small
> > semantic
> > issues forever.  And I think I made a serious effort to keep the
> > patches getting posted over and over again to make sure they got
> > more
> > exposure.
> 
> You can tell them to go to linux-rdma.  I'm sending people to the
> right
> mailing list all the time.

Indeed.  Every single time a patch comes into linux-rdma that touches
things in net/ or include/net, unless it is exceedingly minor, I check
the To:/Cc: lines on the email and if netdev@ isn't included, or in the
case of complex/tricky items, you aren't directly Cc:ed, then I
specifically tell them to include netdev@ and/or you.  I've even had
things like a 12 patch series that buried three netdev@ appropriate
patches at different points in the series and told the submitter to
move all of the netdev@ related patches to the front and submit them to
netdev@ so they can be reviewed as a group before I would move on to
the others.  It's just what you do.  I've always considered that part
of my job.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
