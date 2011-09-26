From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: intel 82599 multi-port performance
Date: Mon, 26 Sep 2011 10:40:24 -0600
Message-ID: <4E80AAF8.1000806@genband.com>
References: <4E805359.2080600@gmail.com> <4E808A41.8040902@genband.com> <4E809D59.10103@gmail.com> <4E80A2AB.2040206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: frog1120@gmail.com, "J.Hwan.Kim" <j.hwan.kim99@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og106.obsmtp.com ([64.18.2.165]:53825 "EHLO
	exprod7og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280Ab1IZQm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 12:42:26 -0400
In-Reply-To: <4E80A2AB.2040206@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2011 10:04 AM, Alexander Duyck wrote:

> It sounds like you are using a single card, would that be correct? If
> you are running close to line rate on both ports this could be causing
> you to saturate the PCIe x8 link.

According to 
"http://communities.intel.com/community/wired/blog/2009/06/08/understanding-pci-express-bandwidth" 
8x PCIe should have a bandwidth of 4GB/s.  2 10Gigabit ports is 2.5GB/s.

The 82599 only goes up to 8x, so I'd expect that it should be sufficient 
to handle the full traffic.

To any of the Intel guys out there...any ideas?  Can an 82599 on an 8x 
bus handle max line rate with minimum size packets?

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
