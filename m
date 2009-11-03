From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name lookups
Date: Tue, 3 Nov 2009 11:45:50 -0500
Message-ID: <20091103164550.GM8227@kvack.org>
References: <20091101163130.GA7911@kvack.org> <20091103035058.GA19515@kroah.com> <4AEFCA49.4020305@gmail.com> <20091103160715.GD23857@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:49759 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbZKCQpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2009 11:45:46 -0500
Content-Disposition: inline
In-Reply-To: <20091103160715.GD23857@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 03, 2009 at 08:07:15AM -0800, Greg KH wrote:
> But registering 20000 devices is a far different problem from using
> those 20000 devices :)

Registering 20,000 devices *is* a real world problem (I'm actually aiming 
for 100,000, as that's what roughly fits in a single 10Gbps link -- something 
that a mid range system can now route).  When an edge router comes up from 
reboot, or after a link has been down, the rate at which customers connect 
is important -- too slow, and you get a pile of support calls from customers 
complaining that their connection is down.  Because of the data structures 
used, there isn't even any improvement from an SMP system, so this needs 
to be addressed directly.

		-ben
