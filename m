From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 9 Oct 2009 10:22:23 -0700
Message-ID: <20091009172223.GA4649@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
 <20091009163613.GA3414@kroah.com>
 <20091009171724.GA11004@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:59064 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751882AbZJIRZf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2009 13:25:35 -0400
Content-Disposition: inline
In-Reply-To: <20091009171724.GA11004@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2009 at 12:17:24PM -0500, Matt Domsch wrote:
> 
> uevents aren't namespaced.  Presumably that means /dev can't be
> polyinstantiated.  Therefore, all devnodes in /dev/netdev/* will be
> visible to all processes, where 'ifconfig' and friends would only show
> device names in the processes namespace.  This doesn't mean the app
> can _do_ anything (it's the same as if it tried to act on a device
> using an ifindex for a device not in its namespace), but yes, the fact
> that such a device exists will be exposed.

That's the problem that the sysfs namespace patches were trying to
address.

Now I'm not saying it is a valid thing to try to work with this kind of
crazy, I was just wondering how it would work out.  Looks like it
doesn't :)

thanks,

greg k-h
