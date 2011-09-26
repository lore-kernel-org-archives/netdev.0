From: Ben Greear <greearb@candelatech.com>
Subject: Re: [E1000-devel] intel 82599 multi-port performance
Date: Mon, 26 Sep 2011 10:24:33 -0700
Message-ID: <4E80B551.1040609@candelatech.com>
References: <4E805359.2080600@gmail.com> <4E808A41.8040902@genband.com> <4E809D59.10103@gmail.com> <4E80A2AB.2040206@intel.com> <4E80AAF8.1000806@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"J.Hwan.Kim" <j.hwan.kim99@gmail.com>, frog1120@gmail.com
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54690 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab1IZRYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 13:24:47 -0400
In-Reply-To: <4E80AAF8.1000806@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2011 09:40 AM, Chris Friesen wrote:
> On 09/26/2011 10:04 AM, Alexander Duyck wrote:
>
>> It sounds like you are using a single card, would that be correct? If
>> you are running close to line rate on both ports this could be causing
>> you to saturate the PCIe x8 link.
>
> According to
> "http://communities.intel.com/community/wired/blog/2009/06/08/understanding-pci-express-bandwidth"
> 8x PCIe should have a bandwidth of 4GB/s.  2 10Gigabit ports is 2.5GB/s.
>
> The 82599 only goes up to 8x, so I'd expect that it should be sufficient
> to handle the full traffic.
>
> To any of the Intel guys out there...any ideas?  Can an 82599 on an 8x
> bus handle max line rate with minimum size packets?

Rick Jones sent me an interesting link related to this.  Short answer seems
to be 'yes', but it seems not for any normal off-the-shelf software stack.

 > This: http://comments.gmane.org/gmane.linux.network/203602 should lead you to some slide.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
