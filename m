From: Carlos Carvalho <carlos@fisica.ufpr.br>
Subject: 2.4: "kernel: hw tcp v4 csum failed" with e100
Date: Mon, 8 Sep 2003 21:03:22 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16221.6346.577173.525623@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've switched from the eepro100 driver to the e100 in 2.4.22-rc2 and
started getting "kernel: hw tcp v4 csum failed" in the logs. Going
back to the eepro100 makes these messages disappear. The machine is
a dual-pentium with the Supermicro DE6 motherboard, which comes with
the Intel ethernet chip on board. ifconfig shows no ethernet errors.

What's the meaning of this warning? I grepped the kernel sources and
found nothing. I'm not even sure it's net-related; I apologize if this
isn't the correct list.
