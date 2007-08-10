From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 1/4] Add ETHTOOL_[GS]FLAGS sub-ioctls
Date: Fri, 10 Aug 2007 16:15:59 -0700
Message-ID: <46BCF1AF.3080000@hp.com>
References: <46BCD47C.9060408@candelatech.com>	<20070810.151039.31642625.davem@davemloft.net>	<46BCE942.1030107@candelatech.com> <20070810.154601.98709831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, jeff@garzik.org, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761313AbXHJX0e@vger.kernel.org>
In-Reply-To: <20070810.154601.98709831.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Fri, 10 Aug 2007 15:40:02 -0700
> 
> 
>>For GSO on output, is there a generic fallback for any driver that
>>does not specifically implement GSO?
> 
> 
> Absolutely, in fact that's mainly what it's there for.
> 
> I don't think there is any issue.  The knob is there via
> ethtool for people who really want to disable it.

Just to be paranoid (who me?) we are then at a point where what happened 
a couple months ago with forwarding between 10G and IPoIB won't happen 
again - where things failed because a 10G NIC had LRO enabled by default?

rick jones
