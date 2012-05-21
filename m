From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH v2] iproute2: trivial fix of ip link syntax in manpage
Date: Mon, 21 May 2012 15:48:06 +0200
Message-ID: <20120521134806.GA29418@amd64.fatal.se>
References: <20120521115850.GA19151@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 673171@bugs.debian.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b22.telenor.se ([195.54.99.213]:35999 "EHLO
	smtprelay-b22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755614Ab2EUNpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 09:45:25 -0400
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-b22.telenor.se (Postfix) with ESMTP id 269DAEAD80
	for <netdev@vger.kernel.org>; Mon, 21 May 2012 15:45:23 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20120521115850.GA19151@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Argh.... template files and generated files also shipped.
Make sure to edit them both to avoid losing the change.

On Mon, May 21, 2012 at 01:58:50PM +0200, Andreas Henriksson wrote:
> Ivan Vilata i Balaguer <ivan@selidor.net> wrote:
> > Hi, I found that the description of the `ip link add` command in the manpage
> > is outdated regarding the compulsory `link DEVICE` option.  For instance, `ip
> > link help` says:
> >
> >     Usage: ip link add [link DEV] [ name ] NAME
> >     ...
> >
> > But the manpage still says:
> >
> >     ip link add link DEVICE [ name ] NAME
> >
> > (Trying to provide a `link` option e.g. under an LXC container can frustrate
> > the creation of dummy devices which don't need an actual device.)
> 
> The syntax of the "ip link help" output was fixed in commit
> "iproute2: Fix usage and man page for 'ip link'" (a22e92951d).
> This updates the manpage to mark "link DEVICE" as an optional
> argument there as well.
> 
> http://bugs.debian.org/673171
> 

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
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index c4fa8c1..9386cc6 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
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
