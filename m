From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Fwd: Receiving MLDv1 reports in a daemon]
Date: Tue, 16 Mar 2004 12:06:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF549FEB55.4E52AD1D-ON88256E59.00681B50-88256E59.0068B106@us.ibm.com>
References: <4057176D.8050206@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4CADFFB9DC08f9e8a93df938690918c07BBE4CADFFB9DC0"
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <4057176D.8050206@us.ibm.com>
To: niv@us.ibm.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4CADFFB9DC08f9e8a93df938690918c07BBE4CADFFB9DC0
Content-type: text/plain; charset=US-ASCII






> Is there any other way to get the MLDv1 reports to my daemon. Any
solution
> to this problem would be very helpful to me.

To receive all MLDv1 reports, you need the interface to be in
multicast promiscuous mode. You can do this by setting the
interface flag "IFF_ALLMULTI".

For MLDv2, reports are sent to the all-multicast-routers group
address, so you only need to join that group in MLDv2.

                                    +-DLS
--0__=07BBE4CADFFB9DC08f9e8a93df938690918c07BBE4CADFFB9DC0
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>&gt; Is there any other way to get the MLDv1 reports to my daemon. Any solution<br>
&gt; to this problem would be very helpful to me.</tt><br>
<br>
<tt>To receive all MLDv1 reports, you need the interface to be in</tt><br>
<tt>multicast promiscuous mode. You can do this by setting the</tt><br>
<tt>interface flag &quot;IFF_ALLMULTI&quot;.</tt><br>
<br>
<tt>For MLDv2, reports are sent to the all-multicast-routers group</tt><br>
<tt>address, so you only need to join that group in MLDv2.<br>
</tt><br>
<tt>						+-DLS</tt></body></html>
--0__=07BBE4CADFFB9DC08f9e8a93df938690918c07BBE4CADFFB9DC0--
