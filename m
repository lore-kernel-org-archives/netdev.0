From: Scott Harrison <scoharr2@cisco.com>
Subject: Re: ixgbe driver fails occasionally since
 ee98b577e7711d5890ded2c7b05578a29512bd39
Date: Fri, 24 Oct 2014 10:18:28 +0100
Message-ID: <20141024091828.GA1488@cisco.com>
References: <20141023140625.GD1480@cisco.com>
 <87618083B2453E4A8714035B62D679925016872B@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aer-iport-3.cisco.com ([173.38.203.53]:1592 "EHLO
	aer-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756030AbaJXJSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 05:18:31 -0400
Content-Disposition: inline
In-Reply-To: <87618083B2453E4A8714035B62D679925016872B@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Emil,

Sorry, I should have looked harder it happens as part of ifup eth0, we have 
"/sbin/ethtool -s eth0 autoneg on" in the interfaces file.

HTH.

Scott.

On Thu, Oct 23, 2014 at 07:48:32PM +0000, Tantilov, Emil S wrote:
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org [mailto:netdev-
>>owner@vger.kernel.org] On Behalf Of Scott Harrison
>>Sent: Thursday, October 23, 2014 7:06 AM
>>To: netdev@vger.kernel.org
>>Subject: ixgbe driver fails occasionally since ee98b577e7711d5890ded2c7b05578a29512bd39
>>
>>Hi,
>>
>>I was asked to raise this issue here.
>>
>>https://bugzilla.kernel.org/show_bug.cgi?id=86591
>>
>>lspci ->
>>
>>03:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
>>03:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
>>
>>With the fibre 10Gbs SFP occasionally on reboot we get
>>
>>[   15.104726] ixgbe 0000:03:00.0 eth0: detected SFP+: 5
>>[   19.735155] ixgbe 0000:03:00.0 eth0: setup link failed with code -14
>
>The error message is from an ethtool command. Where you trying to set the speed to a certain value?
>
>Thanks,
>Emil
>

-- 
Software Engineer

Cisco.com - http://www.cisco.com

This email may contain confidential and privileged material for the sole use of 
the intended recipient. Any review, use, distribution or disclosure by others 
is strictly prohibited. If you are not the intended recipient (or authorised to 
receive for the recipient), please contact the sender by reply email and delete 
all copies of this message.

For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
