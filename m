From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/9] PKT_SCHED: tcf_exts API & make classifier changes consistent upon failure
Date: Thu, 30 Dec 2004 13:26:52 +0100
Message-ID: <20041230122652.GM32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

The following patchset adds tcf_exts API to remove the ifdef clutter,
helps make changes consistent upon failures, makes adding action bits
to yet unsupported classifiers as easy as adding a few lines and
generally saves a lot of code per classifier. The patches to make use
of the API add action support to all classifiers and makes changes
consistent except for indev failures (to be removed soon) and rsvp
which needs a closer look since i haven't had time to perfectly
understand it yet.

I gave it extensive testing for 2 weeks, patches 5-6 are non-trivial
though and it's quite hard to test everything. I will post a request
to the lartc mailinglist once these changes are in a bk release so
everyone can try it out and I have time fix any remaining issues
before the next rc release. I could provide the patchset but its
quite some work for the testers and I guess there will be more people
trying it out if they can use an official release.

Cheers, Thomas
