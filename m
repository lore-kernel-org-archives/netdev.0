From: CaT <cat@zip.com.au>
Subject: ipv6 and ipv4 interaction weirdness
Date: Fri, 11 Mar 2005 23:16:55 +1100
Message-ID: <20050311121655.GE14146@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I just had some issues with ssh and trying to get it to bind to all ipv6
and ipv4 addresses to it via :: and 0.0.0.0. The problem was that it'd
only let one succeed. If 0.0.0.0:22 was successful then :: port 22 could
not happen and neither could my ipv6 addy port 22 as it would get the
'address already in use' error from bind(). The reverse was also true.
If it bound to :: port 22 then 0.0.0.0:22 would fail.

On the other hand if I got it to bind to each address individually then
both ipv4 (2 addresses) and ipv6 (1 address) binds would succeed.

Maybe I'm just looking at it wrong but shouldn't ipv4 and ipv6 interfere
with each other?

I'm using kernel 2.6.11-ac2 with OpenSSH_3.8.1p1 Debian-8.sarge.4,
OpenSSL 0.9.7e 25 Oct 2004 and glibc 2.3.2 (debian version
2.3.2.ds1-20).

-- 
    "It goes against the grain of modern education to teach children to
    program. What fun is there in making plans, acquiring discipline in
    organising thoughts, devoting attention to detail and learning to be
    self-critical?" -- Alan Perlis
