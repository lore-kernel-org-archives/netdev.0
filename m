From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net/mlx4: Mellanox driver update 01-01-2014
Date: Sun, 23 Feb 2014 19:25:04 +0200
Message-ID: <20140223172502.GA27075@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
 <20140219.165049.1684072721398326970.davem@davemloft.net>
 <1393032798.15717.85.camel@deadeye.wl.decadent.org.uk>
 <20140223090142.GA24010@mtl-eit-vdi-22.mtl.labs.mlnx>
 <1393175180.6823.56.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com, yuvala@mellanox.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:34662 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbaBWRZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 12:25:08 -0500
Received: by mail-wg0-f48.google.com with SMTP id a1so3898782wgh.3
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 09:25:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393175180.6823.56.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/02/14 17:06 +0000, Ben Hutchings wrote:
> On Sun, 2014-02-23 at 11:01 +0200, Amir Vadai wrote:
> > On 22/02/14 01:33 +0000, Ben Hutchings wrote:
[...]
> 
> Right, that does sound pretty good as a default.  And I accept that it
> would be reasonable to implement that initially without a tunable beyond
> total number of IRQs.
> 
> I would like to have a central mechanism for this that would allow the
> administrator to set a policy of spreading IRQs across all threads,
> cores, packages, local cores, etc.  (The out-of-tree version of sfc has
> such options.)  If you add the mechanism and default that you've
> proposed, then someone (maybe me) can get round to the configurable
> policy later.
> 
> Ben.
> 

What I'm preparing now is just a very simple helper function that
gets the local numa node and queue number as its inputs, and returns
the recommended cpumask.
A driver that would like to use it, will set using it the
affinity_hint.

This function does seem to be a convenient place for setting different
policies.

Amir.
