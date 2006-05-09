From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network
	device driver.
Date: Tue, 9 May 2006 21:26:11 +0100
Message-ID: <6a1855ab01a195ac2a28a97c5f966f67@cl.cam.ac.uk>
References: <20060509084945.373541000@sous-sol.org>
	<20060509085201.446830000@sous-sol.org>
	<20060509132556.76deaa91@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, Ian Pratt <ian.pratt@xensource.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Wright <chrisw@sous-sol.org>, virtualization@lists.osdl.org
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20060509132556.76deaa91@localhost.localdomain>
To: Stephen Hemminger <shemminger@osdl.org>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org


On 9 May 2006, at 21:25, Stephen Hemminger wrote:

>> +	memcpy(netdev->dev_addr, info->mac, ETH_ALEN);
>> +	network_connect(netdev);
>> +	info->irq = bind_evtchn_to_irqhandler(
>> +		info->evtchn, netif_int, SA_SAMPLE_RANDOM,
>> netdev->name,
>>
>
> This doesn't look like a real random entropy source. packets
> arriving from another domain are easily timed.

Where should we get our entropy from in a VM environment? Leaving the 
pool empty can cause processes to hang.

  -- Keir
