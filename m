From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: must split too big fragments
Date: Fri, 02 Nov 2012 21:58:40 -0400 (EDT)
Message-ID: <20121102.215840.116110325989713705.davem@davemloft.net>
References: <1351000246.8609.1926.camel@edumazet-glaptop>
	<1351021160.8609.2503.camel@edumazet-glaptop>
	<1351531849.12280.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jongman.heo@samsung.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351531849.12280.54.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Oct 2012 18:30:49 +0100

> From: Eric Dumazet <edumazet@google.com>
> 
> vmxnet3 has a 16Kbytes limit per tx descriptor, that happened to work
> as long as we provided PAGE_SIZE fragments.
> 
> Our stack can now build larger fragments, so we need to split them to
> the 16kbytes boundary.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: jongman heo <jongman.heo@samsung.com>
> Tested-by: jongman heo <jongman.heo@samsung.com>
> Cc: Shreyas Bhatewara <sbhatewara@vmware.com>

Applied, thanks everyone.
