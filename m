From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v2 03/14] i40e: Add PF reset when Malicious driver
 event for PF
Date: Tue, 24 Jun 2014 19:16:37 -0700
Message-ID: <1403662597.12657.4.camel@joe-AO725>
References: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1403659585-32055-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Neerav Parikh <neerav.parikh@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0243.hostedemail.com ([216.40.44.243]:34214 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752088AbaFYCQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 22:16:41 -0400
In-Reply-To: <1403659585-32055-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-24 at 18:26 -0700, Jeff Kirsher wrote:
> From: Neerav Parikh <neerav.parikh@intel.com>
> 
> As per the spec when the PF driver receives a Malicious driver event
> the queue that caused the event is already stopped and it is expected
> that the function that owns the queue will reset the queue.
> In some cases it may not be possible to determine the queue and it is
> suggested to reset the whole function.
> 
> This patch takes the later approach when the event is owned by the PF
> that owns it.
> 
> Change-ID: I40f9764a6a5e068c0ef8438db00c5aa9c2c6c1c8
> Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> v2: added punctuation to print statements and code comment

Comments are good, but I'd suggest removing trailing
periods from messages as close to 95% of the messages
in this driver do not use them.

$ grep -rP --include=*.[ch] -oh '.\\n"' drivers/net/ethernet/intel/i40e/| \
  sed 's/[^\.]\\n/X\\n/' | sort | uniq -c | sort -rn
    621 X\n"
     41 .\n"
