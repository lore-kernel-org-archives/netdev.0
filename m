From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: fix for integer overflow in hd6457[02] driver code
Date: Sun, 05 Sep 2004 16:19:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3vfesre5s.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, marcelo.tosatti@cyclades.com,
        <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The attached patch fixes an integer overflow in drivers for N2, C101,
PCI200SYN WAN cards (brv * port->settings.clock_rate overflowed at
requested clock rate of 8*1024*1024 bps, problem noted by Nagaraj Kanniah).

Please apply to 2.4 and 2.6 kernel trees. Thanks.
-- 
Krzysztof Halasa
