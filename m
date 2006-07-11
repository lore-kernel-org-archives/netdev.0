From: shaw@vranix.com
Subject: e1000 TX unit hang (redux)
Date: Tue, 11 Jul 2006 11:16:41 -0700
Message-ID: <200607111116.41932.shaw@vranix.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ws6-3.us4.outblaze.com ([205.158.62.199]:18874 "HELO
	ws6-3.us4.outblaze.com") by vger.kernel.org with SMTP
	id S1750730AbWGKSQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 14:16:42 -0400
To: auke-jan.h.kok@intel.com, kernel@linuxace.com,
	jesse.brandeburg@intel.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello All,

I have an e1000 card periodically misbehaving with the message 'Detected Tx 
unit hang'.   I've noticed this problem come up on netdev a couple of times 
and found the link to the bug tracking page--
http://sourceforge.net/tracker/index.php?func=detail&aid=1463045&group_id=42302&atid=447449

I've also seen the patch that I believe was placed in 2.6.16 and subsequently 
brought down to 2.4.2? that seems to address this problem by creating a 
tx_timeout_factor relative to the speed of the NIC.  However, there is no 
mention of this workaround/fix on the bug at the link above and I haven't 
found any discussion of it here on netdev.   Auke recommends turning off tso 
to see if that resolves the problem and this also seems to work, though I 
have as yet not been able to confirm this and would prefer a more performance 
friendly fix..if available ;)

Would one of you pplease give an update on the status of the bug? If a cause 
was ever found and if the tx_timeout_factor was intended as a fix or 
temporary workaround?   I feel like I must have missed something, because I 
never saw the tx_timeout_factor patch go through netdev at all..

Thanks again for your help,
Shaw
