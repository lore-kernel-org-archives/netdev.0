From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix uninitialized variable issue
Date: Tue, 15 Dec 2015 15:47:20 -0500 (EST)
Message-ID: <20151215.154720.1977313402783880057.davem@davemloft.net>
References: <20151215184617.11620.23369.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	freude@linux.vnet.ibm.com, viro@zeniv.linux.org.uk,
	linux-crypto@vger.kernel.org
To: tadeusz.struk@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20151215184617.11620.23369.stgit@tstruk-mobl1>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tadeusz Struk <tadeusz.struk@intel.com>
Date: Tue, 15 Dec 2015 10:46:17 -0800

> msg_iocb needs to be initialized on the recv/recvfrom path.
> Otherwise afalg will wrongly interpret it as an async call.
> 
> Cc: stable@vger.kernel.org
> Reported-by: Harald Freudenberger <freude@linux.vnet.ibm.com>
> Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>

Looks good, applied, thanks.
