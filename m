From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name
	lookups
Date: Mon, 2 Nov 2009 19:50:58 -0800
Message-ID: <20091103035058.GA19515@kroah.com>
References: <20091101163130.GA7911@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:46080 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757862AbZKCD6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 22:58:14 -0500
Content-Disposition: inline
In-Reply-To: <20091101163130.GA7911@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 01, 2009 at 11:31:30AM -0500, Benjamin LaHaise wrote:
> Use an rbtree in sysfs_dirent to speed up file lookup times
> 
> Systems with large numbers (tens of thousands and more) of network 
> interfaces stress the sysfs code in ways that make the linear search for 
> a name match take far too long.  Avoid this by using an rbtree.

What kind of speedups are you seeing here?  And do these changes cause a
memory increase due to the structure changes which outweigh the
speedups?

What kind of test are you doing to reproduce this?

thanks,

greg k-h
