From: jamal <hadi@cyberus.ca>
Subject: Re: ifconfig TX/RX errors
Date: Fri, 8 Nov 2002 21:00:08 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211082056180.16360-100000@shell.cyberus.ca>
References: <Pine.LNX.4.44.0211082012160.13934-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Cheng Jin <chengjin@cs.caltech.edu>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0211082012160.13934-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 8 Nov 2002, Donald Becker wrote:

> On Fri, 8 Nov 2002, Cheng Jin wrote:
>
> > What does a large number of RX/TX errors from ifconfig output generally
> > mean?  Does it also include drop/overruns/frame errors?
>
> The 'ifconfig' program doesn't have a defined behavior.  It reads
> /proc/net/dev and sums some of the available error counts.  You should
> read /proc/net/dev directly to find out what is going wrong.
>

Actually, unbelievable as it may sound, the ifconfig data
matches SNMP stats as defined in RFC1213 interfaces table;
same with things like netstat -s in the tcp data etc

cheers,
jamal
