From: "Ronnie Sahlberg" <ronnie_sahlberg@ozemail.com.au>
Subject: TCP retransmission timers, questions
Date: Sat, 29 Nov 2003 20:05:08 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <010801c3b657$e3093fb0$6501010a@C5043436>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi list, hope this mail arrives (Im not subscribe to the list, but dont
worry, I read the list through the mailarchive)

By looking at the kernel sources it seems that the minimum TCP
retransmission timeout is hardcoded to 200ms.
Is this correct?

While I understand why it is important to not be too aggressive in
retransmitting I wounder if it would be possible to get
and interface in proc where one could "tune" this.

The reason for this is that in some applications you do have a completely
private, dedicated network used for one specific application.
Those networks can be dimensioned so that congestion "should" not occur.
However, packets are lost from time to time and sometimes packets will be
lost.
In those isolated dedicated subnets, with end to end network latency in the
sub ms range, would it not be useful to be able to allow
the retransmission timeout to drop down to 5-10ms?

Do anyone know of any work/research in the area of tcp retransmission
timeouts for very high bandwidth, low latency networks?
I have checked both the IETF list of drafts, Sally Floyds pages and google
but could not find anything.
It seems to me that all research/experimentation in high throughput is for
high bandwidth high latency links and tuning the slowstart/congestion
avoidance algorithms.
What about high throughput, very low latency?  Does nayone know of any
papers in that area?


For specific applications, running on completely isolated dedicated
networks, dimensioned to make congestion unlikely, isolated so it will NEVER
compete about bandwidth with normal TCPs on the internet,  to me it would
make sense to allow the retransmission timeout to be allowed to drop
significantly below 200ms.


Another question, I think it was RFC2988 (but an not find it again) that
discussed that a TCP may add an artificial delay in sending the packets
based on
the RTT so that when sending an entire window the packets are spaced
equidistantly across the RTT interval instead of in just one big burst.
This to prevent the burstinessd of the traffic and make buffer
overruns/congestion less likely.
I have seen indications that w2k/bsd might in some conditions do this.
Doe Linux do this? my search through the sources came up with nothing.
Does anyone know whether there are other TCPs that do this?
As i said I have seen something that looked like that on a BSD stack but it
could have been related to something else.


best regards
    ronnie
