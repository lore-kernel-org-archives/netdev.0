From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: sysctl variable to force IGMP version [PATCH]
Date: Wed, 28 Jan 2004 20:51:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFE8AE1A1B.D2C2DA34-ON88256E2A.0019F0C1@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4B9DF8A76518f9e8a93df938690918c07BBE4B9DF8A7651"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4B9DF8A76518f9e8a93df938690918c07BBE4B9DF8A7651
Content-type: text/plain; charset=US-ASCII





Dave,
      As it is, it doesn't hurt anything if you set it to "47"-- it'll use
IGMPv1 if it's
set to "1", IGMPv2 if it's set to "2" and IGMPv3 (default) for all other
values. It may
look odd in "sysctl -a" output, but it'll behave reasonably.
      I can add new handler functions used only by this that restrict the
values
(unless there's an easier way using some existing method I don't know
about),
if you think it's worth it, but it won't actually cause any problem if it's
set to any
value out of range.

                        +-DLS


"David S. Miller" <davem@redhat.com>@oss.sgi.com on 01/28/2004 12:00:03 PM

Sent by:    netdev-bounce@oss.sgi.com


To:    David Stevens/Beaverton/IBM@IBMUS
cc:    netdev@oss.sgi.com
Subject:    Re: sysctl variable to force IGMP version [PATCH]



On Tue, 27 Jan 2004 14:13:41 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> Below is a patch that allows forcing of the IGMP version. The primary
> use would be with an IGMP-snooping switch that doesn't grok IGMPv3
> packet formats and when there are no IGMPv2 or IGMPv1 multicast
> routers on the network. By forcing the IGMP reports to version 2 (or
> version 1, for really old switches), Linux would send reports that the
> switch can understand for multicast forwarding to the port.

Perhaps some sanity to prevent values other than 1 or 2 from being
set?


--0__=07BBE4B9DF8A76518f9e8a93df938690918c07BBE4B9DF8A7651
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Dave,<br>
	As it is, it doesn't hurt anything if you set it to &quot;47&quot;-- it'll use IGMPv1 if it's<br>
set to &quot;1&quot;, IGMPv2 if it's set to &quot;2&quot; and IGMPv3 (default) for all other values. It may<br>
look odd in &quot;sysctl -a&quot; output, but it'll behave reasonably.<br>
	I can add new handler functions used only by this that restrict the values<br>
(unless there's an easier way using some existing method I don't know about),<br>
if you think it's worth it, but it won't actually cause any problem if it's set to any<br>
value out of range.<br>
<br>
				+-DLS<br>
<br>

<p><font size="2" color="#800080">Sent by:	netdev-bounce@oss.sgi.com</font>
<p><font size="2" color="#800080">To:	</font><font size="2">David Stevens/Beaverton/IBM@IBMUS</font><br>
<font size="2" color="#800080">cc:	</font><font size="2">netdev@oss.sgi.com</font><font size="2" color="#800080"> </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">Re: sysctl variable to force IGMP version [PATCH]</font><br>
<br>
<br>
<br>
<tt>On Tue, 27 Jan 2004 14:13:41 -0700<br>
David Stevens &lt;dlstevens@us.ibm.com&gt; wrote:<br>
</tt><br>
<tt>&gt; Below is a patch that allows forcing of the IGMP version. The primary<br>
&gt; use would be with an IGMP-snooping switch that doesn't grok IGMPv3<br>
&gt; packet formats and when there are no IGMPv2 or IGMPv1 multicast<br>
&gt; routers on the network. By forcing the IGMP reports to version 2 (or<br>
&gt; version 1, for really old switches), Linux would send reports that the<br>
&gt; switch can understand for multicast forwarding to the port.<br>
</tt><br>
<tt>Perhaps some sanity to prevent values other than 1 or 2 from being<br>
set?</tt><br>
<br>
<br>
</body></html>
--0__=07BBE4B9DF8A76518f9e8a93df938690918c07BBE4B9DF8A7651--
