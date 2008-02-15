From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000: Detected Tx Unit Hang
Date: Fri, 15 Feb 2008 15:29:17 -0800
Message-ID: <47B6204D.8060503@intel.com>
References: <fp553k$9r8$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bernd Schubert <bernd-schubert@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8958 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758946AbYBOXd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 18:33:56 -0500
In-Reply-To: <fp553k$9r8$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernd Schubert wrote:
> Hello,
> 
> I can't login to one of our servers and just got this in an ipmi sol
> session:
> 
> [18169.209181] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [18169.209183]   Tx Queue             <0>
> [18169.209184]   TDH                  <e3>
> [18169.209185]   TDT                  <e3>
> [18169.209186]   next_to_use          <e3>
> [18169.209187]   next_to_clean        <bd>
> [18169.209188] buffer_info[next_to_clean]
> [18169.209189]   time_stamp           <10043e4d2>
> [18169.209190]   next_to_watch        <be>
> [18169.209191]   jiffies              <10043e6f6>
> [18169.209192]   next_to_watch.status <1>
> [18169.256978] e1000: eth2: e1000_clean_tx_irq: Detected Tx Unit Hang
> [18169.256979]   Tx Queue             <0>
> [18169.256980]   TDH                  <de>
> [18169.256982]   TDT                  <de>
> [18169.256983]   next_to_use          <de>
> [18169.256984]   next_to_clean        <bc>
> [18169.256985] buffer_info[next_to_clean]
> [18169.256986]   time_stamp           <10043e511>
> [18169.256987]   next_to_watch        <bd>
> [18169.256988]   jiffies              <10043e701>
> [18169.256989]   next_to_watch.status <1>
> 
> This is with 2.6.22.18. Is there any chance to recover the system? For some
> reasons I would prefer not to reboot now.

if that's all you have then it was false alarm. there should be a 'netdev timeout
- link reset' following those messages. can you send some more context on those
messages?

in real tx hang cases, the hardware is reset within 2 seconds, and everything
continues as normal.

Auke
