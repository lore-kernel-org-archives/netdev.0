From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATHC] (3/10) sk98: use carrrier_on/off
Date: Thu, 18 Nov 2004 14:43:07 -0800
Message-ID: <20041118144307.06df40f7@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Skge drive needs to change the carrier state in response to link up/down,
rather than toggling BSD style IFF_RUNNING.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
