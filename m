From: Andrew Morton <akpm@osdl.org>
Subject: ipvs deadlock fix
Date: Sun, 30 Jan 2005 22:32:46 -0800
Message-ID: <20050130223246.5c6cb398.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I did the following two patches ages ago and haven't really been happy with
the cancel_rearming_delayed_work() thing because it feels livelocky.  

But ipvs does lock up nice and tight so unless there are better ideas...
