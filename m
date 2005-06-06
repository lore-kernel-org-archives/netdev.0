From: jamal <hadi@cyberus.ca>
Subject: Re: [Linux Diffserv] GRED queueing discipline and the file
	sch_gred.c
Date: Mon, 06 Jun 2005 07:54:18 -0400
Message-ID: <1118058859.6266.126.camel@localhost.localdomain>
References: <20050605221106.GB15391@postel.suug.ch>
	 <BAY24-F263AE581155F279A048AE6C5FB0@phx.gbl>
	 <20050606113907.GC15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rahul hari <rahulhsaxena@hotmail.com>,
        diffserv-general@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050606113907.GC15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-06-06 at 13:39 +0200, Thomas Graf wrote:

> Use a prio qdisc with RED leaf qdiscs. RED and GREDs purpose is to
> calculate a marking probability and not to provide any prioritizing
> schemes. 

Prioritization is still implicitly provided if you vary the queue
lengths or the drop probabilities. 
For example, if you set everything to be exactly the same, and varied
only the drop probability - the VQ with the highest drop probability
will be less important (i.e relatively more of its packets will be
dropped; recall: the drop decision is made before the packet is queued).

cheers,
jamal
