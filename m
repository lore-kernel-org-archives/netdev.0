From: Tobias DiPasquale <codeslinger@gmail.com>
Subject: routing table improvements
Date: Sun, 24 Oct 2004 20:19:55 -0400
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <876ef97a04102417193517f48f@mail.gmail.com>
Reply-To: Tobias DiPasquale <codeslinger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: linux-net <linux-net@vger.kernel.org>, netdev <netdev@oss.sgi.com>,
	nf-devel <netfilter-devel@lists.netfilter.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hi all,

I am starting work on improving the routing table in Linux by removing
the route cache altogether and reimplemting the FIB with a radix tree
search implementation. However, I have some questions/RFCs before I
get too deep into it.

First of all, is anyone else doing something in this area?

Second, it doesn't look (to me) as if the lib/radix-tree.c
implementation is sufficiently generic to be used in this capacity.
What I mean is, it appears as if this code can't be used in interrupt
context, which is sort of a necessity for this particular purpose. Am
I just out of my mind or is that the case?

Finally, can anyone think of a reason not use a radix tree search for
the FIB? I was going to implement a simple binary radix tree (similar
to what FreeBSD has). I had originally thought of using something like
CEF uses (a 256-way radix tree), but this would be too
memory-intensive, IMO.

Anyone have any comments?

-- 
[ Tobias DiPasquale ]
0x636f6465736c696e67657240676d61696c2e636f6d
