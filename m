From: jamal <hadi@cyberus.ca>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 5 Sep 2002 21:47:35 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209052129580.21731-100000@shell.cyberus.ca>
References: <1031266115.3d77df4344463@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Troy Wilson <tcw@tempest.prismnet.com>, <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <1031266115.3d77df4344463@imap.linux.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Thu, 5 Sep 2002, Nivedita Singhvi wrote:

>
> > value in your results is in saving on retransmits; I would think
> > shoving the data down the NIC and avoid the fragmentation shouldnt
> > give you that much significant CPU savings. Do you have any stats
>
> Why do say that? Wouldnt the fact that youre now reducing the
> number of calls down the stack by a significant number provide
> a significant saving?

I am not sure; if he gets a busy system in a congested network, i can
see the offloading savings i.e i am not sure if the amortization of the
calls away from the CPU is sufficient enough savings if it doesnt
involve a lot of retransmits. I am also wondering how smart this NIC
in doing the retransmits; example i have doubts if this idea is briliant
to begin with; does it handle SACKs for example? What about
the du-jour algorithm, would you have to upgrade the NIC or can it be
taught some new trickes etc etc.
[also i can see why it makes sense to use this feature only with sendfile;
its pretty much useless for interactive apps]

Troy, i am not interested in the nestat -s data rather the TCP stats
this NIC  has exposed. Unless those somehow show up magically in netstat.

cheers,
jamal
