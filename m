From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: TCP Window Scaling problem with buggy routers FIX works
Date: Mon, 30 Aug 2004 13:00:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <512805293.20040830130037@dns.toxicfilms.tv>
Reply-To: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I am just letting you guys know that the fix for
tcp window scaling problem with buggy routers works.

There were people (including me) reporting that tcp traffic
through some buggy (eg. cisco) routers in linux-2.6.8 slows
down to a crawl.

A workaround was to zero tcp_window_scaling sysctl knob.

With this patch:
http://www.kernel.org/pub/linux/kernel/v2.5/testing/cset/cset-shemminger@osdl.org|ChangeSet|20040826205608|22084.txt

sitting in 2.6.9-rc1 BK repository the linux box can have
fast transfers again.

Note that they are not that fast as with tcp_window_scaling disabled.
But they are certainly fast and will not cause problems like
ssh sessions hangning, etc.

Thanks for the workaround for buggy routers netdev!

Cheers,
Maciej
