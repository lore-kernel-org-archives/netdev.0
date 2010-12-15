From: Patrick McHardy <kaber@trash.net>
Subject: Re: linux-next: Tree for November 18 (netfilter)
Date: Wed, 15 Dec 2010 23:55:10 +0100
Message-ID: <4D09474E.1070100@trash.net>
References: <20101118134256.fe132215.sfr@canb.auug.org.au>	 <20101118092520.6ad964c7.randy.dunlap@oracle.com>	 <4CE5712B.2080909@trash.net>  <1290428077.725556.3.camel@nienna.balabit> <1290428929.726241.1.camel@nienna.balabit> <4CEA97FE.4080006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@balabit.hu>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netfilter-devel@vger.kernel.org, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Balazs Scheidler <bazsi@balabit.hu>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4CEA97FE.4080006@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 22.11.2010 17:19, schrieb Randy Dunlap:
> On 11/22/10 04:28, KOVACS Krisztian wrote:
>> commit ec0ac6f3e7749e25f481c1e0f75766974820fe84
>> Author: KOVACS Krisztian <hidden@balabit.hu>
>> Date:   Mon Nov 22 13:07:15 2010 +0100
>>
>>     netfilter: fix compilation when conntrack is disabled but tproxy is enabled
>>     
>>     The IPv6 tproxy patches split IPv6 defragmentation off of conntrack, but
>>     failed to update the #ifdef stanzas guarding the defragmentation related
>>     fields and code in skbuff and conntrack related code in nf_defrag_ipv6.c.
>>     
>>     This patch adds the required #ifdefs so that IPv6 tproxy can truly be used
>>     without connection tracking.
>>     
>>     Original report:
>>     http://marc.info/?l=linux-netdev&m=129010118516341&w=2
>>     
>>     Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
>>     Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
> 
> That builds.  Thanks.
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks everyone.
