From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario
 which now beyond the range time_after_eq().
Date: Fri, 18 Oct 2013 08:41:41 +0100
Message-ID: <5261025502000078000FBFA9@nat28.tlf.novell.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com>
 <525FBB4F02000078000FBB30@nat28.tlf.novell.com>
 <52600E82.1060604@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	"Jason Luan" <jianhai.luan@oracle.com>, <netdev@vger.kernel.org>
To: "annie li" <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:49808 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943Ab3JRHlo convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Fri, 18 Oct 2013 03:41:44 -0400
In-Reply-To: <52600E82.1060604@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 17.10.13 at 18:21, annie li <annie.li@oracle.com> wrote:
> On 2013-10-17 16:26, Jan Beulich wrote:
>> So first of all this must be with a 32-bit netback. And the not
>> coverable gap between activity is well over 240 days long. _If_
>> this really needs dealing with, then why is extending this from
>> 240+ to 480+ days sufficient?
> 
> I am not so sure your mean about extending from 240+ to 480+. Do you 
> mean "now" wrapped case happens and falls into the range of from expires 
> to next_credit? If this happens, the timer would be set with value based 
> on next_credit, which is actually implements the rate control.

My point was simply that doubling the span the code can cover
is pointless - either 240 days is long enough, of 480 days isn't
either.

Jan
