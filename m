From: Donald Becker <becker@scyld.com>
Subject: Re: ifconfig TX/RX errors
Date: Fri, 8 Nov 2002 20:21:26 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211082012160.13934-100000@beohost.scyld.com>
References: <Pine.LNX.4.33L0.0211081456190.25749-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.33L0.0211081456190.25749-100000@fast2.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Nov 2002, Cheng Jin wrote:

> What does a large number of RX/TX errors from ifconfig output generally
> mean?  Does it also include drop/overruns/frame errors?

The 'ifconfig' program doesn't have a defined behavior.  It reads
/proc/net/dev and sums some of the available error counts.  You should
read /proc/net/dev directly to find out what is going wrong.

The 'ifconfig' and 'netstat' programs follow the interface of their BSD
predecessors.  BSD wasn't sophisticated about errors: it kept only very
basic statistics.  Thus the tools only presented those numbers.

[[ That's not to say I think 'ifconfig' should be changed: there is no
compelling reason to break compatibility.  It's been 20 years since
anyone thought that trailers were a good idea, but it doesn't hurt to
ignore the flag. ]]

> Is it an indication of bad packet on the link layer, which  probably means
> faulty hardware?  I am assuming any kind of buffer overflow statistics are
> kept under drop or overruns?

Check for kernel messages as well.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
