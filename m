From: Patrick McHardy <kaber@trash.net>
Subject: request_module while holding rtnl semaphore
Date: Thu, 04 Nov 2004 04:11:11 +0100
Message-ID: <41899DCF.3050804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There are several instances of request_module beeing called while
holding the rtnl semaphore in net/sched. A pratical problem with
this is the teql scheduler which deadlocks when calling register_netdev
from its init function. A more far-fetched problem would be some crazy
person with their modules in a nfs-mounted directory on a server
reachable over a dial-on-demand link. I couldn't come up with a
solution except for refusing to autoload teql, maybe someone else has
an idea.

Regards
Patrick
