From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Submission for S2io 10GbE driver
Date: Fri, 23 Jan 2004 16:21:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040123162134.79c67ed5.shemminger@osdl.org>
References: <002201c3e1f6$f97896e0$5d50ff11@S2IOtech.com>
	<20040123232209.2739e6aa.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Leonid Grossman" <leonid.grossman@s2io.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040123232209.2739e6aa.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Noticed the setup loopback test seems to register for a packet type
and then forget to unregister that type! 

Also nothing really restricts the packet type to only coming in on the expected
interface; therefore if someone sends the same packet in over another interface,
then sp->loop_pkt_cnt will end up incrementing some other drivers private
data structure *bad*.

IMHO the whole loopback test frame stuff seems like something in a test
bed driver, not production code.
