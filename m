From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target, seq_file version
Date: Thu, 21 Oct 2004 20:41:34 +0200 (CEST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <Pine.LNX.4.61.0410212040270.26969@filer.marasystems.com>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
	<20041021163655.GK3551@sunbeam.de.gnumonks.org>
	<1098380650.1031.82.camel@jzny.localdomain>
	<20041021180324.GL3551@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	jamal <hadi@cyberus.ca>, lmb@suse.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20041021180324.GL3551@sunbeam.de.gnumonks.org>
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

> On Thu, Oct 21, 2004 at 01:44:11PM -0400, jamal wrote:
>>
>> Sorry, couldnt resist - so out of hiding for just a few seconds; should
>> be able to achieve this much simpler with gact.
>
> One of the issues that CLUSTERIP needed to do is to work with
> locally-originated connections, i.e. every node within the cluster still
> has to be able to open tcp connections to anywhere.

Another criteria fulfilled by CLUSTERIP is the ability to do a soft 
failover where the new note accepts all new connections but the old node 
continues processing the connections it already have.

Regards
Henrik
