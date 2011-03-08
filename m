From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/4] slub: automatically reserve bytes at the end of
 slab
Date: Tue, 8 Mar 2011 12:24:07 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1103081222380.25214@router.home>
References: <4D6CA84B.9080606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Pekka Enberg <penberg@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.prem.mail.ac4.yahoo.com ([76.13.13.92]:35207 "HELO
	smtp109.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753315Ab1CHSYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 13:24:11 -0500
In-Reply-To: <4D6CA84B.9080606@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Mar 2011, Lai Jiangshan wrote:

> So we add a field "reserved" to struct kmem_cache, when a slab
> is allocated, kmem_cache->reserved bytes are automatically reserved
> at the end of the slab for slab's metadata.

The reserved field should be exported via sysfs. Please add the code to
show it in /sys/kernel/slab/<name>

