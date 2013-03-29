From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: calxedaxgmac: Wake-on-LAN fixes
Date: Fri, 29 Mar 2013 15:30:04 -0400 (EDT)
Message-ID: <20130329.153004.1825925128455079185.davem@davemloft.net>
References: <1364506365-13689-1-git-send-email-robherring2@gmail.com>
	<1364506365-13689-2-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rob.herring@calxeda.com
To: robherring2@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364506365-13689-2-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <robherring2@gmail.com>
Date: Thu, 28 Mar 2013 16:32:45 -0500

> From: Rob Herring <rob.herring@calxeda.com>
> 
> WOL is broken because the magic packet status bit is getting set rather
> than the enable bit. The PMT interrupt is not getting serviced because
> the PMT interrupt is also enabled on the global interrupt, but not
> cleared by the global interrupt and the global interrupt is higher
> priority. This fixes both of these issues to get WOL working.
> 
> There's still a problem with receive after resume, but at least now we
> can wake-up.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>

Applied.
