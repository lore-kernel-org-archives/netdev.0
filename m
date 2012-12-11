From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH][RFC] smsc95xx: enable dynamic autosuspend (RFC)
Date: Tue, 11 Dec 2012 11:27:50 +0100
Message-ID: <1881907.JmjSTg2PBW@linux-lqwf.site>
References: <1353607526-19307-6-git-send-email-steve.glendinning@shawell.net> <CAKh2mn5LgZBJDJWNzN8A3NK72Vk_fiUjJfmdn5njSrm400q36w@mail.gmail.com> <CACVXFVOBgwoSyUDzxD+ghjkpFu5PL7MuaS5UJOZYvVnV0dwhGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Steve Glendinning <steve@shawell.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:42928 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883Ab2LKK10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 05:27:26 -0500
In-Reply-To: <CACVXFVOBgwoSyUDzxD+ghjkpFu5PL7MuaS5UJOZYvVnV0dwhGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 December 2012 10:24:57 Ming Lei wrote:
> On Mon, Dec 10, 2012 at 10:18 PM, Steve Glendinning <steve@shawell.net> wrote:

> > Thanks, so something like this should do the job?
> 
> This will do, but not simple as clearing .manage_power function
> pointer in bind(), and still disable runtime suspend for link off case
> since these devices which don't support suspend 3 can generate
> remote wakeup for link change event.

So they can autosuspend if the interface is up and no cable is plugged
in?

> I suggest to introduce link-off triggered runtime suspend for these
> usbnet devices(non-LAN9500A device, devices which don't support
> USB auto-suspend), and I have posted one patch set before[1].
> If no one objects that, I'd like to post them again with some fix and
> update for checking link after link_reset().

If you can get rid of a periodic work this would be great.

	Regards
		Oliver
