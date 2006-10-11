From: James K Lewis <jklewis@us.ibm.com>
Subject: Re: [PATCH 0/21]: powerpc/cell spidernet bugfixes, etc.
Date: Wed, 11 Oct 2006 16:06:06 -0500
Message-ID: <OF98E8C8C2.02CDA47C-ON87257204.0073AF96-86257204.0073EA50@us.ibm.com>
References: <200610111802.43996.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0512546125=="
Cc: akpm@osdl.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <200610111802.43996.arnd@arndb.de>
To: Arnd Bergmann <arnd@arndb.de>, jim@jklewis.com
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--===============0512546125==
Content-Type: multipart/alternative; boundary="=_alternative 0073EA4E86257204_="

This is a multipart message in MIME format.
--=_alternative 0073EA4E86257204_=
Content-Type: text/plain; charset="US-ASCII"

Jeff,

  Please apply and forward these Spidernet patches. Thanks!

Jim Lewis
Advisory Software Engineer
IBM Linux Technology Center
512-838-7754






Arnd Bergmann <arnd@arndb.de> 
10/11/2006 11:02 AM

To
Linas Vepstas <linas@austin.ibm.com>
cc
akpm@osdl.org, jeff@garzik.org, James K Lewis/Austin/IBM@ibmus, 
netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
linuxppc-dev@ozlabs.org
Subject
Re: [PATCH 0/21]: powerpc/cell spidernet bugfixes, etc.






On Tuesday 10 October 2006 22:49, Linas Vepstas wrote:
> Andrew, please apply/forward upstream.
> 
> The following set of 21 patches (!) are all aimed at the the 
> spidernet ethernet device driver. The spidernet is an etherenet
> controller built into the Toshiba southbridge for the PowerPC Cell
> processor. (This is the only device in existance that with this
> ethernet hardware in it).
> 
> These patches re-package/re-order/re-cleanup a previous
> set of patches I've previously mailed. Thus, some have
> been previously Acked-by lines, most do not. Most of
> these patches are tiny, and handle problems that cropped
> up during testing. Sorry about there being so many of them.
> 
> The first set of 12 patches fix a large variety of mostly 
> minor bugs. 
> 
> The important patches are 13 through 17: these overcome a 
> debilitating performance problem on transmit (6 megabits
> per second !!) on transmit of patches 500 bytes or larger.
> After applying these, I am able to get the following:
> 
> pkt sz   speed (100K buffs)       speed (4M buffs)
> ------   -----------------        ----------------
> 1500     700 Mbits/sec            951 Mbits/sec
> 1000     658 Mbits/sec            770
> 800      600                      648
> 500      500                      500
> 300      372                      372
> 60        70                       70
> 
> Above buf size refers to /proc/sys/net/core/wmem_default

Excellent work! I guess this the best tx performance we've
seen so far on this hardware.

Consider this as an Acked-by: for all the patches, I'll save
the effort of replying to each one of them separately.

Jeff, do you plan on merging these fixes for 2.6.19?

                 Arnd <><


--=_alternative 0073EA4E86257204_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="sans-serif">Jeff,</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; Please apply and forward these
Spidernet patches. Thanks!</font>
<br><font size=2 face="sans-serif"><br>
Jim Lewis<br>
Advisory Software Engineer<br>
IBM Linux Technology Center<br>
512-838-7754<br>
<br>
<br>
</font>
<br>
<br>
<br>
<table width=100%>
<tr valign=top>
<td width=40%><font size=1 face="sans-serif"><b>Arnd Bergmann &lt;arnd@arndb.de&gt;</b>
</font>
<p><font size=1 face="sans-serif">10/11/2006 11:02 AM</font>
<td width=59%>
<table width=100%>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">To</font></div>
<td><font size=1 face="sans-serif">Linas Vepstas &lt;linas@austin.ibm.com&gt;</font>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">cc</font></div>
<td><font size=1 face="sans-serif">akpm@osdl.org, jeff@garzik.org, James
K Lewis/Austin/IBM@ibmus, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
linuxppc-dev@ozlabs.org</font>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">Subject</font></div>
<td><font size=1 face="sans-serif">Re: [PATCH 0/21]: powerpc/cell spidernet
bugfixes, etc.</font></table>
<br>
<table>
<tr valign=top>
<td>
<td></table>
<br></table>
<br>
<br>
<br><tt><font size=2>On Tuesday 10 October 2006 22:49, Linas Vepstas wrote:<br>
&gt; Andrew, please apply/forward upstream.<br>
&gt; <br>
&gt; The following set of 21 patches (!) are all aimed at the the <br>
&gt; spidernet ethernet device driver. The spidernet is an etherenet<br>
&gt; controller built into the Toshiba southbridge for the PowerPC Cell<br>
&gt; processor. (This is the only device in existance that with this<br>
&gt; ethernet hardware in it).<br>
&gt; <br>
&gt; These patches re-package/re-order/re-cleanup a previous<br>
&gt; set of patches I've previously mailed. Thus, some have<br>
&gt; been previously Acked-by lines, most do not. Most of<br>
&gt; these patches are tiny, and handle problems that cropped<br>
&gt; up during testing. Sorry about there being so many of them.<br>
&gt; <br>
&gt; The first set of 12 patches fix a large variety of mostly <br>
&gt; minor bugs. <br>
&gt; <br>
&gt; The important patches are 13 through 17: these overcome a <br>
&gt; debilitating performance problem on transmit (6 megabits<br>
&gt; per second !!) on transmit of patches 500 bytes or larger.<br>
&gt; After applying these, I am able to get the following:<br>
&gt; <br>
&gt; pkt sz &nbsp; speed (100K buffs) &nbsp; &nbsp; &nbsp; speed (4M buffs)<br>
&gt; ------ &nbsp; ----------------- &nbsp; &nbsp; &nbsp; &nbsp;----------------<br>
&gt; 1500 &nbsp; &nbsp; 700 Mbits/sec &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp;951 Mbits/sec<br>
&gt; 1000 &nbsp; &nbsp; 658 Mbits/sec &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp;770<br>
&gt; 800 &nbsp; &nbsp; &nbsp;600 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;648<br>
&gt; 500 &nbsp; &nbsp; &nbsp;500 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;500<br>
&gt; 300 &nbsp; &nbsp; &nbsp;372 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;372<br>
&gt; 60 &nbsp; &nbsp; &nbsp; &nbsp;70 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 70<br>
&gt; <br>
&gt; Above buf size refers to /proc/sys/net/core/wmem_default<br>
<br>
Excellent work! I guess this the best tx performance we've<br>
seen so far on this hardware.<br>
<br>
Consider this as an Acked-by: for all the patches, I'll save<br>
the effort of replying to each one of them separately.<br>
<br>
Jeff, do you plan on merging these fixes for 2.6.19?<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
Arnd &lt;&gt;&lt;<br>
</font></tt>
<br>
--=_alternative 0073EA4E86257204_=--

--===============0512546125==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============0512546125==--
