From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: sysctl variable to force IGMP version [PATCH]
Date: Fri, 13 Feb 2004 10:31:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF530A0FD3.685C9BE8-ON88256E39.0064C761-88256E39.00658CC3@us.ibm.com>
References: <20040213135020.fd1564f%hibi665@oki.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4AADFF741F18f9e8a93df938690918c07BBE4AADFF741F1"
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040213135020.fd1564f%hibi665@oki.com>
To: Takashi Hibi <hibi665@oki.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4AADFF741F18f9e8a93df938690918c07BBE4AADFF741F1
Content-type: text/plain; charset=US-ASCII





Takashi-san,

> Do you have a plan to make a patch to force the MLD version?
> I think it is also helpful.

      I didn't plan on it. Forcing IGMPv2 is needed for some
switches that do IGMP snooping and don't understand IGMPv3, but
I'm not aware of any switches that do MLD snooping.
      I'd hope even the IGMP-forcing sysctl would be unneeded
within a couple years. It should be unnecessary already when a
multicast router using IGMPv2 is present.

      Do you have a particular need for it for MLDv1? It's an
easy patch, but if it doesn't solve any real problem, I'd say
it shouldn't be done.

                              +-DLS
--0__=07BBE4AADFF741F18f9e8a93df938690918c07BBE4AADFF741F1
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>Takashi-san,</tt><br>
<br>
<tt>&gt; Do you have a plan to make a patch to force the MLD version?<br>
&gt; I think it is also helpful.<br>
</tt><br>
<tt>	I didn't plan on it. Forcing IGMPv2 is needed for some</tt><br>
<tt>switches that do IGMP snooping and don't understand IGMPv3, but</tt><br>
<tt>I'm not aware of any switches that do MLD snooping.</tt><br>
<tt>	I'd hope even the IGMP-forcing sysctl would be unneeded</tt><br>
<tt>within a couple years. It should be unnecessary already when a</tt><br>
<tt>multicast router using IGMPv2 is present.</tt><br>
<br>
<tt>	Do you have a particular need for it for MLDv1? It's an</tt><br>
<tt>easy patch, but if it doesn't solve any real problem, I'd say</tt><br>
<tt>it shouldn't be done.</tt><br>
<br>
<tt>					+-DLS</tt></body></html>
--0__=07BBE4AADFF741F18f9e8a93df938690918c07BBE4AADFF741F1--
