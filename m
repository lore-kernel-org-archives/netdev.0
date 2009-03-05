From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Thu, 05 Mar 2009 01:58:02 -0800 (PST)
Message-ID: <20090305.015802.222446908.davem@davemloft.net>
References: <20090305.005934.130220849.davem@davemloft.net>
	<49AF9672.50200@trash.net>
	<49AF96BE.1020302@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: blaschka@linux.vnet.ibm.com, bart@jukie.net,
	greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754813AbZCEJ6a@vger.kernel.org>
In-Reply-To: <49AF96BE.1020302@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 05 Mar 2009 10:09:18 +0100

> Patrick McHardy wrote:
> > Yes, but that patch introduced the requirement to pass the correct
> > device down since now the handlers need it to get to the ops of the
> > underlying device. Previously they all relied on the handlers not
> > using their private data.

Aha, that's right.

> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> >   
> 
> Oops, the last patch was broken.

Applied, thanks!
