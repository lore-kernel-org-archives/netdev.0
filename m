From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: perm_addr get
Date: Fri, 21 Dec 2012 13:09:55 +0000
Message-ID: <1356095395.7055.34.camel@deadeye.wl.decadent.org.uk>
References: <20121221130127.GB2040@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20058 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab2LUNJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 08:09:59 -0500
In-Reply-To: <20121221130127.GB2040@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 14:01 +0100, Jiri Pirko wrote:
> Hi all.
> 
> From what I understand dev->perm_addr is set only in case the hw has
> permanent hw address somewhere written (for example EPROM).
> 
> So when I query device which does not have perm_addr set I get:
> 
> testt1:~$ ethtool -P team0
> Permanent address: 00:00:00:00:00:00
> 
> Is this the correct behaviour? Wouldn't it be more correct if
> ethtool_get_perm_addr() fails with -ENOENT for something like that?

I don't think we should change the implementation now, as someone might
depend on it.  It's trivial to distinguish this not-a-permanent-address
case.  However the ethtool command output could be improved.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
