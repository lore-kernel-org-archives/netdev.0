From: jamal <hadi@cyberus.ca>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Sun, 15 Sep 2002 16:16:13 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209151053530.22001-100000@shell.cyberus.ca>
References: <20020913.150439.27187393.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <linux-kernel@vger.kernel.org>, <todd-lkml@osogrande.com>,
   <tcw@tempest.prismnet.com>, <netdev@oss.sgi.com>, <pfeather@cs.unm.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020913.150439.27187393.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



10 gige becomes more of an interesting beast. Not sure if we would see
servers with 10gige real soon now. Your proposal does make sense although
compute power would still be a player. I think the key would be
parallelization;
Now if it wasnt for the stupid way TCP options were designed
you could easily do remote DMA instead. Would be relatively easy to add
NIC support for that. Maybe SCTP would save us ;-> however, if history
could be used to predict the future, i think TCP will continue to be
"hacked" and fit the throughput requirements so no chance for SCTP to be
a big player i am afraid .

cheers,
jamal

On Fri, 13 Sep 2002, David S. Miller wrote:

>    From: todd-lkml@osogrande.com
>    Date: Fri, 13 Sep 2002 15:59:15 -0600 (MDT)
>
>    not sure i understand what you're proposing
>
> Cards in the future at 10gbit and faster are going to provide
> facilities by which:
>
> 1) You register a IPV4 src_addr/dst_addr TCP src_port/dst_port cookie
>    with the hardware when TCP connections are openned.
>

[..]
