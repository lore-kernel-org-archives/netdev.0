From: Rodolfo Giometti <giometti@enneenne.com>
Subject: Re: Generic netlink interface help
Date: Sun, 27 May 2007 19:47:59 +0200
Message-ID: <20070527174759.GV21180@enneenne.com>
References: <84po8XY4.1179999810.5490870.samuel@sortiz.org> <1180024477.18003.11.camel@johannes.berg> <20070525221802.GO521@postel.suug.ch> <1180272296.3604.64.camel@johannes.berg> <20070527135014.GQ21180@enneenne.com> <1180274071.3604.66.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-174-11-161.f5.ngi.it ([81.174.11.161]:48884 "EHLO
	mail.enneenne.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbXE0RrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 13:47:25 -0400
Content-Disposition: inline
In-Reply-To: <1180274071.3604.66.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 27, 2007 at 03:54:30PM +0200, Johannes Berg wrote:

> It's written in python without using libnl:
> http://git.sipsolutions.net/pynl80211.git

If I well understand I should do something like this:

	s = socket(PF_NETLINK, SOCK_RAW, NETLINK_GENERIC);

        memset(&src_addr, 0, sizeof(src_addr));
        src_addr.nl_family = AF_NETLINK;
        src_addr.nl_pid = 0;            /* ask kernel to choose an unique ID */
        src_addr.nl_groups = 0;         /* not in mcast groups */
        ret = bind(handle->socket, (struct sockaddr *) &src_addr, sizeof(src_add

to get access to the generic netlink, then I should request the
generic family name but I don't understand in which structure I should
put this request... Can you please halp me?

Thanks a lot,

Rodolfo

-- 

GNU/Linux Solutions                  e-mail:    giometti@enneenne.com
Linux Device Driver                             giometti@gnudd.com
Embedded Systems                     		giometti@linux.it
UNIX programming                     phone:     +39 349 2432127
