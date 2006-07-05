From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000 TX unit hang
Date: Wed, 05 Jul 2006 10:13:34 -0700
Message-ID: <44ABF33E.2020200@intel.com>
References: <20060705163332.GA17915@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60022 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S964914AbWGEROe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 13:14:34 -0400
To: Phil Oester <kernel@linuxace.com>
In-Reply-To: <20060705163332.GA17915@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phil Oester wrote:
> I saw this error (once) in 2.6.13 a few weeks ago:
> 
> Jun 23 15:19:01 X kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> Jun 23 15:19:01 X kernel:   TDH                  <7e>
> Jun 23 15:19:01 X kernel:   TDT                  <7f>
> Jun 23 15:19:01 X kernel:   next_to_use          <7f>
> Jun 23 15:19:01 X kernel:   next_to_clean        <7e>
> Jun 23 15:19:01 X kernel: buffer_info[next_to_clean]
> Jun 23 15:19:01 X kernel:   dma                  <16ef9012>
> Jun 23 15:19:01 X kernel:   time_stamp           <423845db>
> Jun 23 15:19:01 X kernel:   next_to_watch        <7e>
> Jun 23 15:19:01 X kernel:   jiffies              <423845db>
> Jun 23 15:19:01 X kernel:   next_to_watch.status <0>
> 
> so upgraded to 2.6.17 and got a slew of them today - shown below.
> E1000 maintainers: any ideas?

The issue is known and worked on, unfortunately no more information yet.

We're tracking the issue and stuff (debug patches, etc) over here (at 
e1000.sf.net):

http://sourceforge.net/tracker/index.php?func=detail&aid=1463045&group_id=42302&atid=447449

For now, try to see if turning off tso using ethtool helps.


Cheers,

Auke
