From: Stephen Hemminger <shemminger@osdl.org>
Subject: network delay simulation
Date: Tue, 16 Mar 2004 15:10:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Still bumming around for how to easily simulate long latencies.
There is NISTnet but that is fugly old 2.2 code; and Dummynet, and hitbox 
which are FreeBSD based. The existing traffic shaper might do, but it seems
to be limited to lower speed lines and needs some work (using atomic_set
do own locking for instance).

Probably "the cowboy way" would be to right a new net/scheduler to just
do FIFO delay.

Any ideas/comments? Somebody have some code sitting in a drawer?


-- 
Stephen Hemminger 		mailto:shemminger@osdl.org
Open Source Development Lab	http://developer.osdl.org/shemminger
