From: James Morris <jmorris@intercode.com.au>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Sat, 5 Oct 2002 01:06:12 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210050053000.21202-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Pool <mbp@samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin,

I'm not able to reproduce the bug exactly as described.  What kind of
network connection were you using between the boxes, and what was the
kernel version at the server end?  (I've been testing between two boxes on
a 10Mbps lan, with 2.2.22 at the client side and both 2.2.20 and 2.4.19
kernels at the server side).

I'm seeing what looks like some quite buggy behaviour (which needs 
further analysis), but no long term FIN_WAIT1 states.


- James
-- 
James Morris
<jmorris@intercode.com.au>
