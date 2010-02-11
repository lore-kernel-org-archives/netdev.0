From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: Network device and namespace checkpoint/restart (v2)
Date: Thu, 11 Feb 2010 12:26:42 -0500
Message-ID: <4B743DD2.5020304@cs.columbia.edu>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:64729 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755882Ab0BKR1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 12:27:22 -0500
In-Reply-To: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is cool.
I commented on patch 2.
The others (1,3,4) look good to me.

Oren.


Dan Smith wrote:
> This patch set adds checkpoint/restart support for network namespaces,
> as well as the network devices within.  Currently supports veth and loopback
> device types.
> 
> Major changes from last time[1] are:
> 
>  - Add a per-device ndo_checkpoint() operation which simultaneously
>    isolates the checkpoint layer from the network device's checkpoint
>    function and internal data, and also provides a better way to
>    determine checkpointability of a given interface.
>  - Use RTNL to create the veth pair as userspace would, to avoid the
>    need to call directly into RTNL and veth internals
> 
> With this set, I'm able to checkpoint and restart a running sendmail
> instance that is inside a private network namespace with a veth tunnel
> to the outside world.  Applies on top of -rc3 with my other two patches
> from earlier today.
> 
> 1: https://lists.linux-foundation.org/pipermail/containers/2010-January/022549.html
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
