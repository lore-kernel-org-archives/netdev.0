From: "Alan Shih" <alan@storlinksemi.com>
Subject: FW:  Limit skb to be less than 64K with TSO
Date: Tue, 22 Jul 2003 10:18:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <ODEIIOAOPGGCDIKEOPILCEJDCOAA.alan@storlinksemi.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am lost at the following situation:

Env:
I am writing driver + smart NIC's firmware.  The smart NIC has limited
memory. It can do checksum and TSO but with 32K max.

Problem:
SKB may be 64K in size when it reaches the driver. I cannot push all 64K to
the NIC to do checksum.  Is there a way to limit the network stack to give
me only 32K or smaller segments?  If I do checksum in the main processor, it
defeats the purpose.

TIA

Alan
