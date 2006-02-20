From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/02] add mask options to fwmark masking code
Date: Mon, 20 Feb 2006 18:16:30 +0100
Message-ID: <43F9F96E.3040108@trash.net>
References: <23140.1140452813@sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netfilter-devel <netfilter-devel@lists.netfilter.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Michael Richardson <mcr@xelerance.com>
In-Reply-To: <23140.1140452813@sandelman.ottawa.on.ca>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Michael Richardson wrote:
> [PATCH] This patch introduces a mask to the fwmark test cases in the advanced
> routing. This let's one test individual bits of the fwmark to determine
> how things should be routed (pick a routing table). This patch retains
> compatibility with tests that do not set the mask by assuming a mask
> of 0 is equivalent to a mask of 0xffffffff.

One last comment: instead of looking at the value you should check if
the mask attribute is present to decide when to use the compat mask.
