From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: tcp_mib questions
Date: Wed, 26 Mar 2003 14:27:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030326142724.7e8cb865.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

Looking at the Linux tcp_mib, these fields are not updated (set)
AFAICT:

1. 	unsigned long	TcpRtoAlgorithm;
2. 	unsigned long	TcpRtoMin;
3. 	unsigned long	TcpRtoMax;

What retransmit algorithm does Linux use?  or are there several?
I see comments/references to Van Jacobson's algorithm.
Is that the one used, or a variant of it?

4. 	unsigned long	TcpMaxConn;
If TcpMaxConn is dynamic, it can be set to -1.

5. 	unsigned long	TcpEstabResets;
Just not updated anywhere.  Is there a (historical) reason for this,
or it's just omitted, or not wanted?


Any comments or corrections?

Thanks,
--
~Randy
