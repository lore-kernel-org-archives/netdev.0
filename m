From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Fri, 27 Apr 2007 16:48:00 -0700
Message-ID: <46328BB0.9030501@hp.com>
References: <46327A07.1000404@hp.com>	<6.1.2.0.2.20070427153952.13fc7d08@mail.llnl.gov>	<4632894D.40705@hp.com>
	<20070427.163934.106263903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lawver1@llnl.gov, netdev@vger.kernel.org, mst@dev.mellanox.co.il,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070427.163934.106263903.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 27 Apr 2007 16:37:49 -0700
> 
> 
>>Large Receive Offload (LRO) is enabled by default.  This will
>>interfere with forwarding TCP traffic.  If you plan to forward TCP
>>traffic (using the host with the Myri10GE NIC as a router or bridge),
>>you must disable LRO.  To disable LRO, load the myri10ge driver
>>with myri10ge_lro set to 0:
> 
> 
> LRO should be disabled by default if the driver does this.  This is a
> major and unacceptable bug.
> 
> Thanks for pointing this out Rick.

No problem - just to play whatif/devil's advocate for a bit though... is there 
any way to tie that in with the setting of net.ipv4.ip_forward (and/or its IPv6 
counterpart)?

rick jones
