From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Source Specific Query of MLDv2
Date: Thu, 15 Jan 2004 12:47:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFBD24A894.A41FBD39-ON88256E1C.006C2EEB@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE48FDFFFA87B8f9e8a93df938690918c07BBE48FDFFFA87B"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Takashi Hibi <hibi665@oki.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE48FDFFFA87B8f9e8a93df938690918c07BBE48FDFFFA87B
Content-type: text/plain; charset=US-ASCII





Takashi,
      You're right that MLD packets should be excluded from the
interface filters. I'll take a look at this.

Also, it has nothing to do with this problem, but the code is based on
draft 6, so any changes between draft 6 and draft 8 (if there are any
in the protocol) won't be there (yet).

                  thanks!

                        +-DLS


Takashi Hibi <hibi665@oki.com>@oss.sgi.com on 01/15/2004 05:18:41 AM

Sent by:    netdev-bounce@oss.sgi.com


To:    netdev@oss.sgi.com
cc:
Subject:    Source Specific Query of MLDv2



Hi all,

I found another problem of MLDv2.
The host doesn't respond to Source Specific Query.
It happens in the following scenario.

At first, host join multicast address with source address.
Then MLDv2 router issues Source Specific Query.
The source address of the query packet is link-local address of the
router's interface, and the destination address is the multicast address
to be queried. (See section 5.1.4 in draft-vida-mld-v2-08.txt)

But it seems that the query packet is filtered by ipv6_chk_mcast_addr(),
since the source address is not included in the source list.
As a result, no response to the query is produced .

Regards,
Takashi Hibi




--0__=07BBE48FDFFFA87B8f9e8a93df938690918c07BBE48FDFFFA87B
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Takashi,<br>
	You're right that MLD packets should be excluded from the<br>
interface filters. I'll take a look at this.<br>
<br>
Also, it has nothing to do with this problem, but the code is based on<br>
draft 6, so any changes between draft 6 and draft 8 (if there are any<br>
in the protocol) won't be there (yet).<br>
<br>
			thanks!<br>
<br>
				+-DLS<br>
<br>

<p><font size="2" color="#800080">Sent by:	netdev-bounce@oss.sgi.com</font>
<p><font size="2" color="#800080">To:	</font><font size="2">netdev@oss.sgi.com</font><br>
<font size="2" color="#800080">cc:	 </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">Source Specific Query of MLDv2</font><br>
<br>
<br>
<br>
<tt>Hi all,<br>
</tt><br>
<tt>I found another problem of MLDv2.<br>
The host doesn't respond to Source Specific Query.<br>
It happens in the following scenario.<br>
</tt><br>
<tt>At first, host join multicast address with source address.<br>
Then MLDv2 router issues Source Specific Query.<br>
The source address of the query packet is link-local address of the<br>
router's interface, and the destination address is the multicast address<br>
to be queried. (See section 5.1.4 in draft-vida-mld-v2-08.txt)<br>
</tt><br>
<tt>But it seems that the query packet is filtered by ipv6_chk_mcast_addr(),<br>
since the source address is not included in the source list.<br>
As a result, no response to the query is produced .<br>
</tt><br>
<tt>Regards,<br>
Takashi Hibi<br>
</tt><br>
<br>
<br>
<br>
</body></html>
--0__=07BBE48FDFFFA87B8f9e8a93df938690918c07BBE48FDFFFA87B--
