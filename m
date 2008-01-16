From: Ben Greear <greearb@candelatech.com>
Subject: Re: [patch] add net_device_stats support to ethtool
Date: Wed, 16 Jan 2008 10:03:34 -0800
Message-ID: <478E46F6.4070901@candelatech.com>
References: <200801161529.m0GFTfYR005096@sallyv1.ics.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Nicolaescu <dann@ics.uci.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:48579 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291AbYAPSDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 13:03:36 -0500
In-Reply-To: <200801161529.m0GFTfYR005096@sallyv1.ics.uci.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Nicolaescu wrote:
> Hi,
>
> I have posted this patch in the past with absolutely no reply.
> I would appreciate some sort of feedback of the form 
> interested/not interested.  Should I just drop it?
>
>   
I like it, but why not offer this for all devices since they all have 
these stats.
Could add new handlers called something like .get_strings_generic, or
just add this to the higher-level ethtool handling before it looks for 
handlers.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


