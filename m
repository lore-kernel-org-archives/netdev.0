From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]Add new IPv6 MIBs counters support through netlink
Date: Wed, 26 May 2004 13:22:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526132215.06e0bc12.davem@redhat.com>
References: <OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com>
	<200403311326.43647.mashirle@us.ibm.com>
	<200405261308.54281.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200405261308.54281.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 26 May 2004 13:10:05 -0700
Shirley Ma <mashirle@us.ibm.com> wrote:

> This patch implements both per interface and global new IPv6 MIBs counters 
> through netlink based on new IP MIBs draft, 64 bit counters are not supported 
> here because of performance issues. It coexists old IPv6 MIBs counters (which 
> are through proc file system) for the compatibility.

Just to clarify, you named the struct ip_stats because we will use this
eventually for ipv4 as well?  Otherwise we should name it ip6_stats or
something like that.

Otherwise I think your patch is fine.
