From: Greg KH <gregkh@suse.de>
Subject: Re: [RESEND][PATCH 00/11] sysfs tagged directories
Date: Tue, 6 May 2008 10:53:31 -0700
Message-ID: <20080506175331.GA1815@suse.de>
References: <20080506173030.653828076@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <htejun@gmail.com>, Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52608 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759670AbYEFR5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 13:57:13 -0400
Content-Disposition: inline
In-Reply-To: <20080506173030.653828076@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2008 at 07:30:30PM +0200, Benjamin Thery wrote:
> This is still the same port of Eric Biederman's patchset to implement
> tagged directories in sysfs that was discussed a few days ago.
> 
> This time it applies on top of 2.6.26-rc1, 
> which includes a fix from Daniel Lezcano to fix net device renaming
> for sysfs (and of course all the network namespaces stuff that was 
> committed in net-2.6.26).
> 
> This patchset still contains the patch from Serge Hallyn that implements
> tagging for user namespaces.
> 
> It also contains a patch from Daniel Lezcano which allows to have net 
> devices with the same name in two different network namespaces.

Does this all work properly with both CONFIG_SYSFS_DEPRECATED enabled
and disabled?

Can you show some outputs of 'tree' in both cases on the /sys/class/net/
directory?

thanks,

greg k-h
