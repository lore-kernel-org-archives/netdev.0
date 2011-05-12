From: David Miller <davem@davemloft.net>
Subject: Re: [Bridge] Bug#625914: linux-image-2.6.38-2-amd64: bridging is
 not interacting well with multicast in 2.6.38-4
Date: Thu, 12 May 2011 15:59:16 -0700 (PDT)
Message-ID: <20110512.155916.115945119.davem@davemloft.net>
References: <20110510180540.GI6397@morgul.net>
	<20110510151100.52a9f8fa@nehalam>
	<20110510233540.GJ6397@morgul.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, ben@decadent.org.uk,
	625914@bugs.debian.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: noahm@debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40334
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756900Ab1ELW7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:59:48 -0400
In-Reply-To: <20110510233540.GJ6397@morgul.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noah Meyerhans <noahm@debian.org>
Date: Tue, 10 May 2011 16:35:40 -0700

> On Tue, May 10, 2011 at 03:11:00PM -0700, Stephen Hemminger wrote:
>> There were two more follow on commits in stable related to this.
>> I recommend merging 2.6.38.6 which includes these.
> 
> The problem still exists in the current 2.6.38.6.  Backing out 5f1c356a
> still solves the problem there.
> 
> I have not yet tried anything outside the stable-2.6.38.y tree, but it
> seems like these same changes are present there, and it's unlikely that
> other releases will work any better.

So the issue is that if we back out that change, we get crashes.

Aparently there is a code path where whatever is existing in the
SKB ip options block matters, and needs to be maintained.

Someone needs to audit all of this and figure out how to fix the
problem properly.
