From: "Seong Moon" <seong@etri.re.kr>
Subject: dev->hard_header ?
Date: Wed, 20 Nov 2002 11:46:20 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005201c2903f$37e88580$21abfe81@seong>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In Layer 3 Protocols(eg. IP, IPv6, ...),
they calls dev_queue_xmit() to send their data.

Before calling dev_queue_xmit(),
does the layer 3 protocols always call dev->hard_header ?

Actually, I'm not sure when dev->hard_header is called.

I think dev->hard_start_xmit can include the part of dev->hard_header.
Why did the developer seperate the header building and sending frame
fucntion ?

thanks in advance.
