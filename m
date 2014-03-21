From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 14:52:29 -0400 (EDT)
Message-ID: <20140321.145229.1026128975151125729.davem@davemloft.net>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a9cknwk4.fsf@tassilo.jf.intel.com>
	<1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, hpa@zytor.com, kaber@trash.net,
	herbert@gondor.apana.org.au, hkchu@google.com, mwdalton@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Mar 2014 05:50:50 -0700

> It looks like a barrier() would be more appropriate.

barrier() == __asm__ __volatile__(:::"memory")
