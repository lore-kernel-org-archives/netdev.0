From: Roger Luethi <rl@hellgate.ch>
Subject: pci-skeleton duplex check
Date: Wed, 11 Dec 2002 14:24:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021211132436.GA12529@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

pci-skeleton (and some other net drivers) figure out the duplex setting
like this (leaving duplex locks out here):

int duplex = (lpar & 0x0100) || (lpar & 0x01C0) == 0x0040;

If we get past the first condition, we already know bit 8 must be 0. Why do
we check again in the second condition?

Roger
