From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bridge] Bug#625914: linux-image-2.6.38-2-amd64: bridging is
 not interacting well with multicast in 2.6.38-4
Date: Fri, 13 May 2011 11:03:26 -0700
Message-ID: <20110513110326.60fa09b4@nehalam>
References: <20110506201234.6297.70279.reportbug@ip6-localhost>
	<1304995124.4065.157.camel@localhost>
	<20110510043833.GG6397@morgul.net>
	<1305031369.4065.259.camel@localhost>
	<20110510180540.GI6397@morgul.net>
	<20110510151100.52a9f8fa@nehalam>
	<20110510233540.GJ6397@morgul.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>, 625914@bugs.debian.org,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Noah Meyerhans <noahm@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57910 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751910Ab1EMSE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 14:04:26 -0400
In-Reply-To: <20110510233540.GJ6397@morgul.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011 16:35:40 -0700
Noah Meyerhans <noahm@debian.org> wrote:

> On Tue, May 10, 2011 at 03:11:00PM -0700, Stephen Hemminger wrote:
> > There were two more follow on commits in stable related to this.
> > I recommend merging 2.6.38.6 which includes these.
> 
> The problem still exists in the current 2.6.38.6.  Backing out 5f1c356a
> still solves the problem there.
> 
> I have not yet tried anything outside the stable-2.6.38.y tree, but it
> seems like these same changes are present there, and it's unlikely that
> other releases will work any better.
> 
> noah
> 

Is this unique to the tap interfaces or does bridging multicast
not work for all devices?


-- 
