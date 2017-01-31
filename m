From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: ANNOUNCE: Netdev 2.1 update
Date: Tue, 31 Jan 2017 09:15:24 -0500
Message-ID: <251ff72a-01b7-9c57-6181-eb45d66ba070@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        info@netdevconf.org, linux-wireless@vger.kernel.org,
        tech-committee@netdevconf.org, David Miller <davem@davemloft.net>,
        Stephen Jaworski <jaws@mojatatu.com>,
        Rob Echlin <rob@echlin.ca>, lwn@lwn.net
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A few announcements:
- We expect to open up registration and announce hotel and location
next week.

- We are pleased to announce the first netdev 2.1 talk has been accepted
by the tech committee! The Call for Proposals is still open, submit 
early to avoid the hazards of last minute traffic. Refer to:
http://netdevconf.org/1.2/submit-proposal.html

On to the accepted talk:
-------
Title: Evaluating and improving kernel stack performance for datagram 
sockets
        from the perspective of RDBMS applications

Authors: Sowmini Varadhan, Tushar Dave

RDBMS applications heavily use stateless datagram sockets such as RDS
and UDP. These workloads  are typically highly CPU-bound and sensitive
to network latency, so any perf improvements to these parameters is 
extremely
desirable.

At the same time, since I/O for these RDBMS  applications comes
from various sources (network, disk, local file-system and NFS),
APIs for perf enhancements is also a critical factor.

Motivated by these goals and constraints, we have investigated a few
kernel alternatives to UDP/IP, such as PF_PACKET.  We have used
micro-benchmarks such as netperf, and are currently evaluating PF_PACKET
usage in IPC libraries for actual transaction-oriented RDBMS workloads.

We would like to share some of the findings from these experiments with
the netdev community. In addition to the actual numbers themselves,
interesting points that we'd like to discuss are the gaps between
micro-benchmarks and real-world usage, what works well (and what
doesn't matter so much) for real workloads, and practical factors
that impact deployment for any solution.

This is active work-in-progress, and some of our findings suggest areas
of perf-improvement in the kernel for various datagram sockets
that we'd like to bounce off netdev-ers for input.
---------------

cheers,
jamal
