From: "Art Haas" <ahaas@airmail.net>
Subject: Current kernel and cvs/rsync problems
Date: Tue, 25 Jan 2005 09:05:14 -0600
Message-ID: <20050125150514.GA2262@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

I'm running the current BK kernel on my machine. As the subject stated
both cvs and rsync are not working correctly under this kernel, while
they work fine under a kernel built from BK sources several days prior
to the release of the -rc2 kernel. Watching cvs with strace I can
observe that the various file tests run without problems, but once cvs
starts the network activity with write() or read() calls things just
hang.

While both cvs and rsync fail under the -rc2+ kernels, other programs
like subversion and BitKeeper still work, and I can view web things with
Mozilla without problem.

Is anyone seeing similar behavior with the current BK kernel?

Art Haas
-- 
Man once surrendering his reason, has no remaining guard against absurdities
the most monstrous, and like a ship without rudder, is the sport of every wind.

-Thomas Jefferson to James Smith, 1822
