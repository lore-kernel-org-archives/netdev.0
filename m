From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Receiving MLDv1 reports in a daemon
Date: Tue, 16 Mar 2004 20:29:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF2E982703.9E2B5218-ON88256E5A.0017CCF8-88256E5A.0018566D@us.ibm.com>
References: <Pine.LNX.4.33.0403170944260.23954-100000@pcz-madhavis.sasken.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4C9DF844A688f9e8a93df938690918c07BBE4C9DF844A68"
Cc: madhavis@sasken.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.33.0403170944260.23954-100000@pcz-madhavis.sasken.com>
To: Madhavi <madhavis@sasken.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4C9DF844A688f9e8a93df938690918c07BBE4C9DF844A68
Content-type: text/plain; charset=US-ASCII







madhavis@sasken.com wrote on 03/16/2004 08:15:25 PM:

> Is there any other way to get the MLDv1 reports to my daemon. Any
solution
> to this problem would be very helpful to me.

As I responded before, though you may not have seen it, you need to put
the device in "multicast promiscuous mode" by setting the IFF_ALLMULTI
interface flag (SIOCSIFFLAGS). Then you should receive all multicasts for
all groups (and all protocols) sent on that network. If you create the
socket as you described, your program should receive all ICMPv6
multicasts sent to any group.

In MLDv2, it's much easier. All reports are sent to the "all multicast
routers" multicast address, so you can simply join that group.

                              +-DLS
--0__=07BBE4C9DF844A688f9e8a93df938690918c07BBE4C9DF844A68
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>madhavis@sasken.com wrote on 03/16/2004 08:15:25 PM:<br>
</tt><br>
<tt>&gt; Is there any other way to get the MLDv1 reports to my daemon. Any solution<br>
&gt; to this problem would be very helpful to me.<br>
</tt><br>
<tt>As I responded before, though you may not have seen it, you need to put</tt><br>
<tt>the device in &quot;multicast promiscuous mode&quot; by setting the IFF_ALLMULTI</tt><br>
<tt>interface flag (SIOCSIFFLAGS). Then you should receive all multicasts for</tt><br>
<tt>all groups (and all protocols) sent on that network. If you create the</tt><br>
<tt>socket as you described, your program should receive all ICMPv6</tt><br>
<tt>multicasts sent to any group.</tt><br>
<br>
<tt>In MLDv2, it's much easier. All reports are sent to the &quot;all multicast</tt><br>
<tt>routers&quot; multicast address, so you can simply join that group.</tt><br>
<br>
<tt>					+-DLS</tt></body></html>
--0__=07BBE4C9DF844A688f9e8a93df938690918c07BBE4C9DF844A68--
