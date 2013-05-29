From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: igb: acknowledging time sync interrupts
Date: Wed, 29 May 2013 17:42:50 +0000
Message-ID: <CDCB8BE0.1EC2C%matthew.vick@intel.com>
References: <20130528160654.GC4678@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:30108 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932812Ab3E2RnO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 13:43:14 -0400
In-Reply-To: <20130528160654.GC4678@netboy>
Content-Language: en-US
Content-ID: <4547455BCB6EBE42BF7780B6B5E35CEC@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/28/13 9:06 AM, "Richard Cochran" <richardcochran@gmail.com> wrote:

>On Tue, May 28, 2013 at 03:20:10PM +0000, Vick, Matthew wrote:
>> 
>> I'll start some internal discussion to see if I can get an official
>>answer
>> on the 82580.
>
>Okay, that sounds good. I just posted a patch that removes the wr32(),
>and I can report that it does work on the i210. If the 82580 needs
>this workaround, then I can add it back in again.
>
>Thanks,
>Richard

Following up internally, we got confirmation 82580 does have an issue with
the read of TSICR not clearing it. Please do add the wr32 back in and keep
an eye out for updated documentation.

Cheers,
Matthew
