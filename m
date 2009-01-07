From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net: reset network device counters on the fly
Date: Tue, 06 Jan 2009 18:29:45 -0800
Message-ID: <49641399.80305@hp.com>
References: <3375b4020901061808g527cb872ia64b47147783b91c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Huascar Tejeda <htejeda@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:45845 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110AbZAGC3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 21:29:47 -0500
In-Reply-To: <3375b4020901061808g527cb872ia64b47147783b91c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Huascar Tejeda wrote:
> Hello everyone,
> 
> This is my first post to the mailing list and also my first kernel patch.
> 
> There was an scenario where I needed to clear network device counters
> without shutting down the interface.
> With this patch I add this functionality to /proc/net/dev.
> 
> Usage example:
> echo clear eth0 > /proc/net/dev
> echo clear all > /proc/net/dev
> 
> Thanks for your comments and please feel free to reply with any
> suggestions you may have.

Having been at least once bitten as a patch submittor, I'll point-out 
that patches are generally requested to be inline, not attachments. 
Also, in any kernel tree there should be a file describing how a patch 
should be put together and what addtional bits of information need to be 
included.  That file is ./Documentation/SubmittingPatches.

Finally, my recollection is this same sort of thing (zeroing counters) 
has been proposed before, and shot-down.  Doesn't a priori mean it will 
be shot-down this time, but it suggests the chances are slim.  You can 
probably find the discussion in one or more of the various archives for 
the netdev list.  For those situations where you want to know the 
statistics for a given interval, you can snap the stats to files at 
either end of the interval and run them through "beforeafter" or 
something similar:

http://ftp.cup.hp.com/dist/networking/tools/

rick jones
wondering what has become of his ethtool patch to recognize speeds other 
than 10/100/1000/10000... perhaps it too tripped over some of the above :(
