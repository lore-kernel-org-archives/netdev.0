From: jamal <hadi@cyberus.ca>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: 25 Jan 2004 14:07:16 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075057635.1747.76.camel@jzny.localdomain>
References: <002401c3e2b3$94038d70$0400a8c0@S2IOtech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <002401c3e2b3$94038d70$0400a8c0@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-01-24 at 14:52, Leonid Grossman wrote:

> > What would also be interesting to see is a packet that never
> > leaves the kernel such is in forwarding. If theres a way you 
> > can stash two of those cards in a box and just have them 
> > forward packets coming in from one to another - would be nice 
> > to see the numbers with varying packet size example { 
> > 64,256,512,1518, 4K, 9K} 
> > 
> > cheers,
> > jamal
> 
> 
> Hi Jamal, 
> Are you suggesting to run a benchmark between two back-to-back hosts,
> and then run the same benchmark between the two hosts via a third box
> (with two 10GbE cards) that would just forward traffic, and compare the
> results? 
> Or you had a different setup in mind? 

Just a simple test for packets that dont cross user space - kernel
boundary. Example forwarding of some form where a packet comes in,
data gets touched (ttl, csum etc) and gets forwarded to the egress port.
The setup will include a single box with two NICs; one connected to a
traffic generator source the other to a sink which records stats.
The interesting measurements will packet latency and throughput.
Get a off the shelf traffic generator like an IXIA (pktgen may be used
too); i.e forget ttcp and relatives.
For starters you could even have a packet coming in and being DMAed to
the otehr NIC untouched.

> Not sure what the application for something like this would be (I think
> 10GbE will be mainly deployed in a datacenter for a while), but we can
> probably run something like that and get the numbers; I'll let you know.
> 

Apps would be any middle box (router, firewall, accounting etc).
Interest is more from a linux side what can we do to improve things.

cheers,
jamal
