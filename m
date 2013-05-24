From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Fri, 24 May 2013 11:34:46 -0500
Message-ID: <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:57464 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007Ab3EXQet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 12:34:49 -0400
Received: by mail-ob0-f173.google.com with SMTP id eh20so5638224obb.4
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 09:34:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 10:49:31AM -0500, Shawn Bohrer wrote:
> I just started testing the 3.10 kernel, previously we were on 3.4 so
> there is a fairly large jump.  I've additionally applied the following
> four patches to the 3.10.0-rc2 kernel that I'm testing:
> 
> https://patchwork.kernel.org/patch/2484651/
> https://patchwork.kernel.org/patch/2484671/
> https://patchwork.kernel.org/patch/2484681/
> https://patchwork.kernel.org/patch/2484641/
> 
> I don't know if those patches are related to my issues or not but I
> plan on trying to reproduce without them soon.

I've reverted the four patches above from my test kernel and still see
the issue so they don't appear to be the cause.

--
Shawn
