From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [PATCH 2.6] iptables CONNMARK match+target
Date: Thu, 21 Oct 2004 12:25:35 +0200 (CEST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <Pine.LNX.4.61.0410211215580.19600@filer.marasystems.com>
References: <20041020222102.GO19899@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0410210912280.18310@filer.marasystems.com>
	<20041021091632.GB3551@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20041021091632.GB3551@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004, Harald Welte wrote:

>> Is this with or without the mark operations?
>
> What is 'this' you are referring to?

The CONNMARK patch.

> 'very useful'? Yes, indeed.  I think it is already very useful, even
> without MARK bit-wise operations (which AFAIK are not implemented with
> the required compatibility issues we discussed at the netfilter
> workshop, but which will be submitted once this is done).

This is what I am talking about, and answers my question.

The MARK bit-wise operations is also available for CONNMARK and could in 
theory be included in CONNMARK when submitted to the kernel as this won't 
break compatibility with existing kernels (only patched kernels), but 
probably not worth it unless the same functionality is also available in 
MARK which we currently can't do due to the compatibility issue..

Once the compatibility issue is solved for MARK there should not be a 
problem to use the same to extend CONNMARK with mark bitwise operations if 
not included in the initial submission.

I am fine either way.

Regards
Henrik
