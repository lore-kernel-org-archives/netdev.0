From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] abysmal e1000 performance (DITR)
Date: Thu, 26 Aug 2004 16:26:50 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <412E478A.2000806@pobox.com>
References: <468F3FDA28AA87429AD807992E22D07E014CEF36@orsmsx408>	 <1093542930.1027.124.camel@jzny.localdomain> <1093550644.20769.130.camel@tubarao>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: tharbaugh@lnxi.com
In-Reply-To: <1093550644.20769.130.camel@tubarao>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thayne Harbaugh wrote:
> On Thu, 2004-08-26 at 13:55 -0400, jamal wrote:
> 
>>Ganesh,
>>
>>Can you please make this feature off by default and perhaps
>>accesible via ethtool for peopel who want to turn it on.
>>I just wasted a few hours and was bitten by this performance-wise.
>>Please consider disabling it.
> 
> 
> This is a *horrible* problem.  Even though it's fixable by passing a
> module parameter, the default bites those that *know* about it.  We have
> had customers bitten by this and customers that have insisted in
> swapping all the NICs in a cluster to Broadcom TG3 NICs.
> 
> It's a black eye for Intel and a loss of business - that's the opinion
> of our customers.


If it's so bad we should disable it by default, either via the module 
parameter or via a kernel CONFIG_xxx option.

	Jeff
