From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 12:41:29 -0400 (EDT)
Message-ID: <20170516.124129.292555623308256441.davem@davemloft.net>
References: <20170516.122923.869994491617365845.davem@davemloft.net>
        <20170516163041.GA5132@lst.de>
        <1494952561.3259.104.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: hch@lst.de, Bart.VanAssche@sandisk.com,
        torvalds@linux-foundation.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, stable@vger.kernel.org,
        ubraun@linux.vnet.ibm.com
To: dledford@redhat.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1494952561.3259.104.camel@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Ledford <dledford@redhat.com>
Date: Tue, 16 May 2017 12:36:01 -0400

> On Tue, 2017-05-16 at 18:30 +0200, Christoph Hellwig wrote:
>> On Tue, May 16, 2017 at 12:29:23PM -0400, David Miller wrote:
>> > 
>> > I can't push back on people with silly coding style and small
>> > semantic
>> > issues forever.  And I think I made a serious effort to keep the
>> > patches getting posted over and over again to make sure they got
>> > more
>> > exposure.
>> 
>> You can tell them to go to linux-rdma.  I'm sending people to the
>> right
>> mailing list all the time.
> 
> Indeed.  Every single time a patch comes into linux-rdma that touches
> things in net/ or include/net, unless it is exceedingly minor, I check
> the To:/Cc: lines on the email and if netdev@ isn't included, or in the
> case of complex/tricky items, you aren't directly Cc:ed, then I
> specifically tell them to include netdev@ and/or you.  I've even had
> things like a 12 patch series that buried three netdev@ appropriate
> patches at different points in the series and told the submitter to
> move all of the netdev@ related patches to the front and submit them to
> netdev@ so they can be reviewed as a group before I would move on to
> the others.  It's just what you do.  I've always considered that part
> of my job.

To be quite honest it wasn't exceedingly clear, even to me, that this
had such implications or was directly a RDMA thing.  From my
perspective while reviewing I saw a patch series adding it's own
protocol stack living inside of it's own directory under net/

And, if even one RDMA/infiniband person said to me "you really
shouldn't apply this" then I would have dropped it on the spot.
