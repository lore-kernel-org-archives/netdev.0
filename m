From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 12:29:23 -0400 (EDT)
Message-ID: <20170516.122923.869994491617365845.davem@davemloft.net>
References: <1494788929.21774.1.camel@sandisk.com>
        <20170514.204404.1844909849561204299.davem@davemloft.net>
        <1494950224.3259.98.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Bart.VanAssche@sandisk.com, torvalds@linux-foundation.org,
        hch@lst.de, netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: dledford@redhat.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1494950224.3259.98.camel@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Ledford <dledford@redhat.com>
Date: Tue, 16 May 2017 11:57:04 -0400

> Regardless though, I'm rather purturbed about this entire thing.  If
> you are right that because this got into 4.11, it's now a done deal,
> then the fact that this went through 4 review cycles on netdev@ that,
> as I understand it, spanned roughly one years time, and not one single
> person bothered to note that this was as much an RDMA driver as
> anything else, and not one person bothered to note that linux-rdma@ was
> not on the Cc: list, and not one person told the submitters that they
> needed to include linux-rdma@ on the Cc: list of these submissions, and
> you took it without any review comments from any RDMA people in the
> course of a year, or an ack from me to show that the RDMA portion of
> this had at least been given some sort of review, was a collosal fuckup
> of cross tree maintainer cooperation.

We rely on people from various areas of expertiece to contribute to
patch review on netdev and give appropriate feedback.

If you actually look through the history, I made many semantic reviews
of the SMC changes, and kept pushing back.

And in fact I did this several times, making them go through several
revisions, in the hopes that someone would review more of the meat and
substance of the patch set.

Nobody do this for over a year.

I can't push back on people with silly coding style and small semantic
issues forever.  And I think I made a serious effort to keep the
patches getting posted over and over again to make sure they got more
exposure.

I think it's unsettling that there are no RDMA experts, or at least
people remotely knowledgable about this "networking" technology,
subscribed to netdev and taking a cursory look at pactches that might
be relevant and effect that technology either directly or indirectly.

So there is a lot of blame to go around.
