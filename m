From: Andreas Henriksson <andreas@fatal.se>
Subject: Bug#673171: [PATCH] iproute2: trivial fix of ip link syntax in
	manpage
Date: Mon, 21 May 2012 13:58:50 +0200
Message-ID: <20120521115850.GA19151@amd64.fatal.se>
Reply-To: Andreas Henriksson <andreas@fatal.se>, 673171@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 673171@bugs.debian.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.673171.B673171.133760139124143@bugs.debian.org>
Content-Disposition: inline
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Ivan Vilata i Balaguer <ivan@selidor.net> wrote:
> Hi, I found that the description of the `ip link add` command in the manpage
> is outdated regarding the compulsory `link DEVICE` option.  For instance, `ip
> link help` says:
>
>     Usage: ip link add [link DEV] [ name ] NAME
>     ...
>
> But the manpage still says:
>
>     ip link add link DEVICE [ name ] NAME
>
> (Trying to provide a `link` option e.g. under an LXC container can frustrate
> the creation of dummy devices which don't need an actual device.)

The syntax of the "ip link help" output was fixed in commit
"iproute2: Fix usage and man page for 'ip link'" (a22e92951d).
This updates the manpage to mark "link DEVICE" as an optional
argument there as well.

http://bugs.debian.org/673171

Signed-off-by: Andreas Henriksson <andreas@fatal.se>


diff --git a/man/man8/ip-link.8 b/man/man8/ip-link.8
index 72f4cfd..24d2ec7 100644
--- a/man/man8/ip-link.8
+++ b/man/man8/ip-link.8
@@ -23,7 +23,9 @@ ip-link \- network device configuration
 \fB\-o\fR[\fIneline\fR] }
 
 .ti -8
-.BI "ip link add link " DEVICE
+.BI "ip link add"
+.RB "[ " link
+.IR DEVICE " ]"
 .RB "[ " name " ]"
 .I NAME
 .br
