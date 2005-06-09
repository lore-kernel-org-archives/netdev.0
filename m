From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 09 Jun 2005 15:21:19 -0700 (PDT)
Message-ID: <20050609.152119.55508630.davem@davemloft.net>
References: <Pine.LNX.4.62.0506091406590.10396@ladlxr>
	<20050609150546.61b0fee7@unknown-215.office.pdx.osdl.net>
	<Pine.LNX.4.62.0506091510560.16917@ladlxr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, hadi@cyberus.ca, john.ronciak@intel.com,
        mitch.a.williams@intel.com, mchan@broadcom.com, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.LNX.4.62.0506091510560.16917@ladlxr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Thu, 9 Jun 2005 15:12:09 -0700 (PDT)

> I saw that... somehow iptables got compiled into kernel statically.  no 
> rules are active or installed  iptables -L -n shows nothing in any chain.

Netfilter can kill performance, even if no rules are loaded at all.
Please take that out of your kernel.
