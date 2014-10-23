From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH 1/3] xen-netback: make feature-rx-notify mandatory
Date: Thu, 23 Oct 2014 12:37:54 +0100
Message-ID: <5448E892.9010307@citrix.com>
References: <1413983335-8307-1-git-send-email-david.vrabel@citrix.com> <1413983335-8307-2-git-send-email-david.vrabel@citrix.com> <20141023111629.GE9188@zion.uk.xensource.com> <20141023113206.GF9188@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46051 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480AbaJWLh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 07:37:56 -0400
In-Reply-To: <20141023113206.GF9188@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/10/14 12:32, Wei Liu wrote:
> On Thu, Oct 23, 2014 at 12:16:29PM +0100, Wei Liu wrote:
>> On Wed, Oct 22, 2014 at 02:08:53PM +0100, David Vrabel wrote:
>>> Frontends that do not provide feature-rx-notify may stall because
>>> netback depends on the notification from frontend to wake the guest Rx
>>> thread (even if can_queue is false).
>>>
>>> This could be fixed but feature-rx-notify was introduced in 2006 and I
>>> am not aware of any frontends that do not implement this.
>>>
>>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>>
>> Acked-by: Wei Liu <wei.liu2@citrix.com>
> 
> While I can understand this patch by itself, can you elaborate a little
> bit on how it affects later patches? Because what I'm thinking is that
> this patch is not for stable while other two should go to stable.

>From the cover letter:

"The first patch is a prerequite.  Removing support for frontends with
feature-rx-notify makes it easier to reason about the correctness of
netback since it no longer has to support this outdated and broken
mode."

The other patches do not meet the stable kernel requirements (they're
too long one thing).

David
