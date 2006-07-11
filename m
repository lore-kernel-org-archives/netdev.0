From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000 TX unit hang (redux)
Date: Tue, 11 Jul 2006 14:09:47 -0700
Message-ID: <44B4139B.7060907@intel.com>
References: <200607111116.41932.shaw@vranix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, kernel@linuxace.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63351 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932127AbWGKVK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 17:10:27 -0400
To: shaw@vranix.com
In-Reply-To: <200607111116.41932.shaw@vranix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shaw@vranix.com wrote:
> I have an e1000 card periodically misbehaving with the message 'Detected Tx 
> unit hang'.   I've noticed this problem come up on netdev a couple of times 
> and found the link to the bug tracking page--
> http://sourceforge.net/tracker/index.php?func=detail&aid=1463045&group_id=42302&atid=447449
> 
> I've also seen the patch that I believe was placed in 2.6.16 and subsequently 
> brought down to 2.4.2?

that's not only impossible but also unlikely - we don't push changes to 2.4 
kernels anymore a lot, I think the last change is likely older than 2.4.28 or so.

 > that seems to address this problem by creating a
> tx_timeout_factor relative to the speed of the NIC.  However, there is no 
> mention of this workaround/fix on the bug at the link above and I haven't 
> found any discussion of it here on netdev. 

I wouldn't even know what patch you are talking about (?!)

> Auke recommends turning off tso 
> to see if that resolves the problem and this also seems to work, though I 
> have as yet not been able to confirm this and would prefer a more performance 
> friendly fix..if available ;)
> 
> Would one of you pplease give an update on the status of the bug? If a cause 
> was ever found and if the tx_timeout_factor was intended as a fix or 
> temporary workaround?   I feel like I must have missed something, because I 
> never saw the tx_timeout_factor patch go through netdev at all..

One possible problem is a bad EEPROM bit, where the hardware might have been 
misconfigured. This only affects _some_ older e1000's. Any bugreport therefore 
should include the output of `ethtool -e ethX` (as well as the `lspci -vv` 
output of course. If you haven't already done so, please submit this to the 
bugtracker or to us by e-mail

Cheers,

Auke
