From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [Linux Diffserv] GRED queueing discipline and the file sch_gred.c
Date: Mon, 6 Jun 2005 14:15:27 +0200
Message-ID: <20050606121527.GE15391@postel.suug.ch>
References: <20050605221106.GB15391@postel.suug.ch> <BAY24-F263AE581155F279A048AE6C5FB0@phx.gbl> <20050606113907.GC15391@postel.suug.ch> <1118058859.6266.126.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rahul hari <rahulhsaxena@hotmail.com>,
        diffserv-general@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1118058859.6266.126.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1118058859.6266.126.camel@localhost.localdomain> 2005-06-06 07:54
> On Mon, 2005-06-06 at 13:39 +0200, Thomas Graf wrote:
> 
> > Use a prio qdisc with RED leaf qdiscs. RED and GREDs purpose is to
> > calculate a marking probability and not to provide any prioritizing
> > schemes. 
> 
> Prioritization is still implicitly provided if you vary the queue
> lengths or the drop probabilities. 
> For example, if you set everything to be exactly the same, and varied
> only the drop probability - the VQ with the highest drop probability
> will be less important (i.e relatively more of its packets will be
> dropped; recall: the drop decision is made before the packet is queued).

Absolutely, what I meant is that GRED does not take influence on the
actual ordering of packets not dropped. The priority together with
the qavg parameters and the thresholds only have influence on the
probability a packet gets marked/dropped, sure this is prioritization
as well but Rahul wanted to have one VQ strave out another VQ
completely. My point is that this is not possible with GRED.
