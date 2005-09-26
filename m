From: Michael Bellion <mbellion@hipac.org>
Subject: [ANNOUNCE] Release of nf-HiPAC 0.9.0
Date: Mon, 26 Sep 2005 04:45:46 +0200
Message-ID: <200509260445.46740.mbellion__24708.3482835025$1127703454$gmane$org@hipac.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

I am happy to announce the release of nf-HiPAC version 0.9.0

During the development of version 0.9.0 everything was ported to Linux kernel 
2.6 and large parts of the kernel code have been rewritten.
The kernel patch is now fairly non-intrusive: it only adds one simple function 
to ip_tables.c. The rest of the patch introduces new files to the kernel. 
The new release fixes all known bugs and also introduces some new features.

Since the last release I have become part of MARA Systems AB 
( http://www.marasystems.com ). MARA Systems AB is now the commercial backer 
of the HiPAC Project and finances it completely. Together MARA Systems and I 
will make sure that HiPAC is actively maintained and further developed under 
the GNU GPL.


For all of you who don't know nf-HiPAC yet, here is a short overview:

nf-HiPAC is a full featured packet filter for Linux which demonstrates the
power and flexibility of HiPAC. HiPAC is a novel framework for packet
classification which uses an advanced algorithm to reduce the number of
memory lookups per packet. It is ideal for environments involving large rule
sets and/or high bandwidth networks.

nf-HiPAC provides the same rich feature set as iptables, the popular Linux
packet filter. The complexity of the sophisticated HiPAC packet
classification algorithm is hidden behind an iptables compatible user
interface which renders nf-HiPAC a drop-in replacement for iptables. Thereby,
the iptables' semantics of the rules is preserved, i.e. you can construct your
rules like you are used to. From a user's point of view there is no need to
understand anything about the HiPAC algorithm.

The nf-hipac user space tool is designed to be as compatible as possible to
'iptables -t filter'. It even supports the full power of iptables targets,
matches and stateful packet filtering (connection tracking) besides the native
nf-HiPAC matches. This makes a switch from iptables to nf-HiPAC very easy.
Usually it is sufficient to replace the calls to iptables with calls to
nf-hipac for your filter rules.

Why another packet filter?
Performance:
    iptables, like most packet filters, uses a simple packet classification
    algorithm which traverses the rules in a chain linearly per packet until a
    matching rule is found (or not). Clearly, this approach lacks efficiency.
    As networks grow more and more complex and offer a wider bandwidth linear
    packet filtering is no longer an option if many rules have to be matched
    per packet. Higher bandwidth means more packets per second which leads to
    shorter process times per packet. nf-HiPAC outperforms iptables regardless
    of the number of rules, i.e. the HiPAC classification engine does not
    impose any overhead even for very small rule sets.

Scalability to large rule sets:
    The performance of nf-HiPAC is nearly independent of the number of rules.
    nf-HiPAC with thousands of rules still outperforms iptables with 20 rules.

Dynamic rule sets:
    nf-HiPAC offers fast dynamic rules et updates without stalling packet
    classification in contrast to iptables which yields bad update performance
    along with stalled packet processing during updates.

More information about the project can be found at:    http://www.hipac.org
The releases are published on:    http://sourceforge.net/projects/nf-hipac/

Enjoy,
    +---------------------------+
    |      Michael Bellion      |
    |   <mbellion@hipac.org>    |
    +---------------------------+
