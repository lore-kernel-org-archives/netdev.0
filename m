From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Strange uses of netif_start_queue
Date: Fri, 12 Aug 2005 14:35:14 +0100
Message-ID: <1123853714.22460.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Something I noticed doing the tty work. the 6pack driver calls
netif_start_queue() before it calls register_netdev. I'm curious if this
is allowed ?
