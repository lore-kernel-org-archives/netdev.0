From: Jeff Garzik <jgarzik@pobox.com>
Subject: dev->xmit_lock_owner?
Date: Tue, 18 Feb 2003 13:33:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218183306.GA31478@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hum.

It seems that dev_watchdog, among other places, does not assign a value
to dev->xmit_lock_owner, when it takes the lock.

I think this is a bug, but could be wrong ;-)
