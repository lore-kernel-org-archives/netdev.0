From: Asim Shankar <asimshankar@gmail.com>
Subject: Re: filtering packtes before OS takes care about them
Date: Mon, 28 Feb 2005 14:09:56 -0600
Message-ID: <7bca1cb50502281209798e8a00@mail.gmail.com>
References: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Weber Matthias <weber@faps.uni-erlangen.de>
In-Reply-To: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> i need a possibility to catch IP4 packets (from ethernet devices) before OS' netmodules (IP, UDP, TCP, ICMP, ARP, ROUTE, NETFILTER ...) takes care about them and
> * to delete them from input buffer such that OS' netmodules can't receive them
> * to modify packet headers and move packets to interface related output buffers
> * to keep them in input buffers such that OS' netmodules can take care about them.

You can process packets even before ip_rcv() gets them by registering
your own packet handler (struct packet_type) using dev_add_pack().  I
have a small sample at:
http://limnos.csrd.uiuc.edu/notes/code-samples/samples/kernel/packet_type/packet_type_test.c
This may not be the cleanest way, but it isn't that dirty either.

Also see:
http://www.phrack.org/show.php?p=55&a=12

-- Asim
