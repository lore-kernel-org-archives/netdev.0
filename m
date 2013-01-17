From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [net-next 12/14] igb: Add mechanism for detecting latched
 hardware Rx timestamp
Date: Thu, 17 Jan 2013 16:51:09 +0000
Message-ID: <CD1D6B33.FD1F%matthew.vick@intel.com>
References: <20130117153812.GB2937@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31276 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751804Ab3AQQvL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 11:51:11 -0500
In-Reply-To: <20130117153812.GB2937@netboy.at.omicron.at>
Content-Language: en-US
Content-ID: <7FBBB5F72FBB2144818DB6247658AA73@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/17/13 7:38 AM, "Richard Cochran" <richardcochran@gmail.com> wrote:

>On Thu, Jan 17, 2013 at 03:35:17AM -0800, Jeff Kirsher wrote:
>> From: Matthew Vick <matthew.vick@intel.com>
>> 
>> Add a check against possible Rx timestamp freezing in the hardware via
>> watchdog mechanism. This situation can occur when an Rx timestamp has
>>been
>> latched, but the packet has been dropped because the Rx ring is full.
>
>Does this also need fixing in stable?
>
>The igb patches look okay to me.
>
>Acked-by: Richard Cochran <richardcochran@gmail.com>

Thanks for the review, Richard!

I'm not too particularly worried about getting this one into stable. This
is to prevent it from theoretically occurring rather than a bug fix for an
issue someone has reported. Plus, it only really affects 82576, as for
82580 and newer we put the timestamp in the packet buffer instead of the
RXSTMP registers. I think it's good to have this fix in going forward,
though.
