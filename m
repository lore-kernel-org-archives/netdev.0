From: esr@thyrsus.com
Subject: Problems in bridge.8, ip-netns.8, ip-maddress.8, ip-tunnel.8,
 ip-route.8, ip-neighbour.8, ip-rule.8
Date: Tue, 18 Jun 2013 01:14:05 -0400 (EDT)
Message-ID: <20130618051405.06917417E7@snark.thyrsus.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2582064486436101362=="
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:52327
	"EHLO snark.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186Ab3FRFVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 01:21:23 -0400
Received: from [127.0.1.1] (localhost [127.0.0.1])
	by snark.thyrsus.com (Postfix) with ESMTP id 06917417E7
	for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 01:14:05 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--===============2582064486436101362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

This is automatically generated email about markup problems in a man
page for which you appear to be responsible.  If you are not the right
person or list, please tell me so I can correct my database.

See http://catb.org/~esr/doclifter/bugs.html for details on how and
why these patches were generated.  Feel free to email me with any
questions.  Note: These patches do not change the modification date of
any manual page.  You may wish to do that by hand.

I apologize if this message seems spammy or impersonal. The volume of
markup bugs I am tracking is over five hundred - there is no real
alternative to generating bugmail from a database and template.

--
                             Eric S. Raymond

--===============2582064486436101362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Problems with ip-route.8:

Presentation-level use of SS could not be structurally
translated. I changed lower-level instances to .TP.

--- ip-route.8-unpatched	2013-06-01 06:58:12.898961138 -0400
+++ ip-route.8	2013-06-01 06:58:34.070960742 -0400
@@ -246,10 +246,16 @@
 .I policy routing
 is used.
 
-.SS ip route add - add new route
-.SS ip route change - change route
-.SS ip route replace - change or add new one
-
+.TP
+ip route add
+add new route
+.TP
+ip route change
+change route
+.TP
+ip route replace
+change or add new one
+.RS
 .TP
 .BI to " TYPE PREFIX " (default)
 the destination prefix of the route.  If
@@ -502,9 +508,12 @@
 .B onlink
 pretend that the nexthop is directly attached to this link,
 even if it does not match any interface prefix.
+.RE
 
-.SS ip route delete - delete route
-
+.TP
+ip route delete
+delete route
+.RS
 .B ip route del
 has the same arguments as
 .BR "ip route add" ,
@@ -518,8 +527,12 @@
 If no route with the given key and attributes was found,
 .B ip route del
 fails.
+.RE
 
-.SS ip route show - list routes
+.TP
+ip route show
+list routes
+.RS
 the command displays the contents of the routing tables or the route(s)
 selected by some criteria.
 
@@ -628,8 +641,12 @@
 .TP
 .BI realms " FROMREALM/TOREALM"
 only list routes with these realms.
+.RE
 
-.SS ip route flush - flush routing tables
+.TP
+ip route flush
+flush routing tables
+.RS
 this command flushes routes selected by some criteria.
 
 .sp
@@ -652,8 +669,12 @@
 .B ip route flush
 also dumps all the deleted routes in the format described in the
 previous subsection.
+.RE
 
-.SS ip route get - get a single route
+.TP
+ip route get
+get a single route
+.RS
 this command gets a single route to a destination and prints its
 contents exactly as the kernel sees it.
 
@@ -707,21 +728,30 @@
 .B iif
 argument, the kernel pretends that a packet arrived from this interface
 and searches for a path to forward the packet.
+.RE
 
-.SS ip route save - save routing table information to stdout
-this command behaves like
+.TP
+ip route save
+save routing table information to stdout
+.RS
+This command behaves like
 .BR "ip route show"
 except that the output is raw data suitable for passing to
 .BR "ip route restore" .
+.RE
 
-.SS ip route restore - restore routing table information from stdin
-this command expects to read a data stream as returned from
+.TP
+ip route restore
+restore routing table information from stdin
+.RS
+This command expects to read a data stream as returned from
 .BR "ip route save" .
 It will attempt to restore the routing table information exactly as
 it was at the time of the save, so any translation of information
 in the stream (such as device indexes) must be done first.  Any existing
 routes are left unchanged.  Any routes specified in the data stream that
 already exist in the table will be ignored.
+.RE
 
 .SH EXAMPLES
 .PP

--===============2582064486436101362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Problems with ip-rule.8:

Presentation-level use of SS could not be structurally
translated. I changed lower-level instances to .TP.

Use of low-level troff hackery to set special indents or breaks can't
be translated. The page will have rendering faults in HTML, and
probably also under third-party man page browsers such as Xman,
Rosetta, and the KDE help browser.  This patch eliminates .br, .ta, .ti,
.ce, .in, and \h in favor of requests like .RS/.RE that have
structural translations.

--- ip-rule.8-unpatched	2013-05-27 18:56:19.558789754 -0400
+++ ip-rule.8	2013-05-27 19:00:39.002784902 -0400
@@ -140,7 +140,7 @@
 .sp
 The RPDB may contain rules of the following types:
 
-.in +8
+.RS
 .B unicast
 - the rule prescribes to return the route found
 in the routing table referenced by the rule.
@@ -158,12 +158,14 @@
 .B nat
 - the rule prescribes to translate the source address
 of the IP packet into some other value.
-.in -8
-
-.SS ip rule add - insert a new rule
-.SS ip rule delete - delete a rule
+.RE
 
 .TP
+.B ip rule add - insert a new rule
+.TP
+.B ip rule delete - delete a rule
+.RS
+.TP
 .BI type " TYPE " (default)
 the type of this rule.  The list of valid types was given in the previous
 subsection.
@@ -237,11 +239,14 @@
 immediately.  It is assumed that after a script finishes a batch of
 updates, it flushes the routing cache with
 .BR "ip route flush cache" .
+.RE
 
-.SS ip rule flush - also dumps all the deleted rules.
+.TP
+.B ip rule flush - also dumps all the deleted rules.
 This command has no arguments.
 
-.SS ip rule show - list rules
+.TP
+.B ip rule show - list rules
 This command has no arguments.
 The options list or lst are synonyms with show.
 

--===============2582064486436101362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Problems with ip-neighbour.8:

Presentation-level use of SS could not be structurally
translated. I changed lower-level instances to .TP.

Spelling error or typo.

Use of low-level troff hackery to set special indents or breaks can't
be translated. The page will have rendering faults in HTML, and
probably also under third-party man page browsers such as Xman,
Rosetta, and the KDE help browser.  This patch eliminates .br, .ta, .ti,
.ce, .in, and \h in favor of requests like .RS/.RE that have
structural translations.

--- ip-neighbour.8-unpatched	2013-05-27 18:34:19.418814443 -0400
+++ ip-neighbour.8	2013-05-27 18:38:00.970810299 -0400
@@ -46,10 +46,17 @@
 The corresponding commands display neighbour bindings
 and their properties, add new neighbour entries and delete old ones.
 
-.SS ip neighbour add - add a new neighbour entry
-.SS ip neighbour change - change an existing entry
-.SS ip neighbour replace - add a new entry or change an existing one
+.TP
+ip neighbour add
+add a new neighbour entry
+.TP
+ip neighbour change
+change an existing entry
+.TP
+ip neighbour replace
+add a new entry or change an existing one
 
+.PP
 These commands create new neighbour records or update existing ones.
 
 .TP
@@ -74,31 +81,28 @@
 is an abbreviation for 'Neighbour Unreachability Detection'.
 The state can take one of the following values:
 
-.in +8
+.TP
 .B permanent
-- the neighbour entry is valid forever and can be only
+the neighbour entry is valid forever and can be only
 be removed administratively.
-.sp
-
+.TP
 .B noarp
-- the neighbour entry is valid. No attempts to validate
+the neighbour entry is valid. No attempts to validate
 this entry will be made but it can be removed when its lifetime expires.
-.sp
-
+.TP
 .B reachable
-- the neighbour entry is valid until the reachability
+the neighbour entry is valid until the reachability
 timeout expires.
-.sp
-
+.TP
 .B stale
-- the neighbour entry is valid but suspicious.
+the neighbour entry is valid but suspicious.
 This option to
 .B ip neigh
 does not change the neighbour state if it was valid and the address
 is not changed by this command.
-.in -8
-
-.SS ip neighbour delete - delete a neighbour entry
+.RS
+ip neighbour delete - delete a neighbour entry
+.RE
 This command invalidates a neighbour entry.
 
 .PP
@@ -120,9 +124,11 @@
 .B NOARP
 interface or if the address is multicast or broadcast.
 
-.SS ip neighbour show - list neighbour entries
+.RS
+ip neighbour show - list neighbour entries
+.RE
 
-This commands displays neighbour tables.
+This command displays neighbour tables.
 
 .TP
 .BI to " ADDRESS " (default)
@@ -154,7 +160,10 @@
 and
 .BR "noarp" .
 
-.SS ip neighbour flush - flush neighbour entries
+.RS
+ip neighbour flush - flush neighbour entries
+.RE
+
 This command flushes neighbour tables, selecting
 entries to flush by some criteria.
 

--===============2582064486436101362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Problems with bridge.8:

Broken command synopsis syntax.  This may mean you're using a
construction in the command synopsis other than the standard
[ ] | { }, or it may mean you have running text in the command synopsis
section (the latter is not technically an error, but most cases of it
are impossible to translate into DocBook markup), or it may mean the
command syntax fails to match the description.

--- bridge.8-unpatched	2013-05-26 15:02:53.902732701 -0400
+++ bridge.8	2013-05-26 15:03:09.650732407 -0400
@@ -7,21 +7,11 @@
 .in +8
 .ti -8
 .B bridge
-.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.RI "[ " -V | -Version | -s | -statistics " ] [ " fdb "|" monitor " ] { " COMMAND " | "
 .BR help " }"
 .sp
 
 .ti -8
-.IR OBJECT " := { "
-.BR fdb " | " monitor " }"
-.sp
-
-.ti -8
-.IR OPTIONS " := { "
-\fB\-V\fR[\fIersion\fR] |
-\fB\-s\fR[\fItatistics\fR]
-
-.ti -8
 .BR "bridge fdb" " { " add " | " del " } "
 .I LLADDR
 .B  dev

--===============2582064486436101362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Problems with ip-netns.8:

Presentation-level use of SS could not be structurally
translated. I changed lower-level instances to .TP.

--- ip-netns.8-unpatched	2013-05-27 18:23:17.802826816 -0400
+++ ip-netns.8	2013-05-27 18:24:32.858825412 -0400
@@ -53,12 +53,19 @@
 bind mounting all of the per network namespace configure files into
 their traditional location in /etc.
 
-.SS ip netns list - show all of the named network namespaces
-.SS ip netns add NAME - create a new named network namespace
-.SS ip netns delete NAME - delete the name of a network namespace
-.SS ip netns exec NAME cmd ... - Run cmd in the named network namespace
-
 .SH EXAMPLES
+.TP
+ip netns list
+show all of the named network namespaces
+.TP
+ip netns add NAME
+create a new named network namespace
+.TP
+ip netns delete NAME
+delete the name of a network namespace
+.TP
+ip netns exec NAME cmd ...
+Run cmd in the named network namespace
 
 .SH SEE ALSO
 .br

--===============2582064486436101362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Problems with ip-maddress.8:

Presentation-level use of SS could not be structurally
translated. I changed lower-level instances to .TP.

--- ip-maddress.8-unpatched	2013-05-27 18:49:33.834797342 -0400
+++ ip-maddress.8	2013-05-27 18:49:45.906797116 -0400
@@ -25,19 +25,24 @@
 .B maddress
 objects are multicast addresses.
 
-.SS ip maddress show - list multicast addresses
-
+.TP
+.B ip maddress show - list multicast addresses
+.RS
 .TP
 .BI dev " NAME " (default)
 the device name.
+.RE
 
-.SS ip maddress add - add a multicast address
-.SS ip maddress delete - delete a multicast address
+.TP
+.B ip maddress add - add a multicast address
+.TP
+.B ip maddress delete - delete a multicast address
+.sp
 these commands attach/detach a static link layer multicast address
 to listen on the interface.
 Note that it is impossible to join protocol multicast groups
 statically.  This command only manages link layer addresses.
-
+.RS
 .TP
 .BI address " LLADDRESS " (default)
 the link layer multicast address.
@@ -45,6 +50,7 @@
 .TP
 .BI dev " NAME"
 the device to join/leave this multicast address.
+.RE
 
 .SH SEE ALSO
 .br

--===============2582064486436101362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Problems with ip-tunnel.8:

Presentation-level use of SS could not be structurally
translated. I changed lower-level instances to .TP.

--- ip-tunnel.8-unpatched	2013-05-27 19:02:51.386782427 -0400
+++ ip-tunnel.8	2013-05-27 19:05:39.450779284 -0400
@@ -85,10 +85,16 @@
 .B -f
 option.  The default is IPv4.
 
-.SS ip tunnel add - add a new tunnel
-.SS ip tunnel change - change an existing tunnel
-.SS ip tunnel delete - destroy a tunnel
-
+.TP
+.B ip tunnel add
+add a new tunnel
+.TP
+.B ip tunnel change
+change an existing tunnel
+.TP
+.B ip tunnel delete
+destroy a tunnel
+.RS
 .TP
 .BI name " NAME " (default)
 select the tunnel device name.
@@ -215,9 +221,12 @@
 .BI flowlabel " FLOWLABEL"
 .RB ( " only IPv6 tunnels " )
 set a fixed flowlabel.
+.RE
 
-.SS ip tunnel prl - potential router list (ISATAP only)
-
+.TP
+.B ip tunnel prl
+potential router list (ISATAP only)
+.RS
 .TP
 .BI dev " NAME"
 mandatory device name.
@@ -230,8 +239,11 @@
 .BI prl-delete " ADDR"
 .RB "Add or delete " ADDR
 as a potential router or default router.
+.RE
 
-.SS ip tunnel show - list tunnels
+.TP
+.B ip tunnel show
+list tunnels
 This command has no arguments.
 
 .SH SEE ALSO

--===============2582064486436101362==--
