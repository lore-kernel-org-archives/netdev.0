From: Greg <gvrose8192@gmail.com>
Subject: Re: Question on i40e PCIe relaxed ordering (RO)
Date: Wed, 29 Jun 2016 13:18:39 -0700
Message-ID: <1467231519.3404.11.camel@gmail.com>
References: <57742A27.5040207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: tndave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34678 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbcF2U1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 16:27:18 -0400
Received: by mail-pa0-f51.google.com with SMTP id bz2so20633055pad.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 13:26:34 -0700 (PDT)
In-Reply-To: <57742A27.5040207@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-29 at 13:05 -0700, tndave wrote:
> Hi,
> 
> Running iperf tcp test on 2 sparc systems with i40e connected back to
> back, I see huge number of 'port.rx_dropped' (on iperf server). Based on
> past experience with ixgbe, this could very well because of PCIe RO
> (relaxed ordering) not enabled.
> 
> I am trying to confirm RO is enabled. i40e datasheet mentioned RO
> settings in 3 different sections:
> 
> 1. section 10.2.2.2.38 PCIe Global Config 2 - GLPCI_CNF2 register
> contains global status fields of PCIe configuration. The bit 0 of the
> register is "RO_DIS". If this bit is set to 1 RO is disabled.
> 
> RO_DIS in my setup is 0 imply RO is not disabled.
> 
> 2. section 12.3.5.5 Device Control Register (0xA8; RW) has bit 4
> that enable/disable RO. This is pcie cap register.
> 
> In my i40e pcie config space value at offset 0xA8 is "2110". i.e 4th bit
> set to 1 imply RO is enabled.
> 
> 3. section 3.1.2.7.2 mentions some relaxed ordering rules
> e.g. "The GLLAN_RCTL.RXDESCRDROEN bit (loaded from NVM) enables relaxed
> ordering for Rx descriptor reads"
> 
> However, GLLAN_RCTL register definition has not bit like RXDESCRDROEN.
> Same goes for GLLAN_TCTL.TXDESCRDROEN.
> 
> Am I missing anything? please advise.

I would try posting this question to the e1000 developer list over at
Source Forge.  The Intel customer support folks used to monitor that
list closely when I was there, hopefully they still are.

Regards,

- Greg

> 
> Thanks.
> 
> -Tushar
> 
> (Ref:http://www.intel.com/content/dam/www/public/us/en/documents/datasheets/xl710-10-40-controller-datasheet.pdf)
> 
> 
> 
