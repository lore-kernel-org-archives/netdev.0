From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target
Date: Thu, 21 Oct 2004 08:44:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021074450.GA1093@infradead.org>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>, David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@oss.sgi.com>,
        Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
        lmb@suse.de
Content-Disposition: inline
In-Reply-To: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 21, 2004 at 12:38:28AM +0200, Harald Welte wrote:
> Hi Dave!
> 
> This is the second patch, adding the 'CLUSTERIP' target to iptables. It
> depends on the first 'CONNMARK' patch.
> 
> This enables you to build a static load sharing cluster between multiple
> nodes - without the requirement to have a load balancer.  It uses a
> series of [evil] tricks like replying with linklayer multicast addresses
> to ARP requests, and using CONNMARK for stateful blocking all traffic
> not intended for the local node.
> 
> Apart from the usual netfilter-specific file additions and
> Kconfig/Makefile patches, this needs to export proc_file_operations in
> order to get the reference counting of certain data objects right.  I
> hope this change is acceptable.

The export is totally bogus.  If you need to do fancy things procfs is
the wrong interface.  Care to explain why exactly you think you need it?
