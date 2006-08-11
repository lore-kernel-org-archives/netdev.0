From: James K Lewis <jklewis@us.ibm.com>
Subject: Re: [PATCH 4/4]: powerpc/cell spidernet ethtool -i version number
	info.
Date: Fri, 11 Aug 2006 13:50:19 -0500
Message-ID: <OF934FE4E3.EEC44FDD-ON872571C7.00668651-862571C7.00677A44@us.ibm.com>
References: <20060811180013.GB6550@pb15.lixom.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1825548729=="
Cc: Arnd Bergmann <arnd@arndb.de>, Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20060811180013.GB6550@pb15.lixom.net>
To: Olof Johansson <olof@lixom.net>
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
--===============1825548729==
Content-Type: multipart/alternative; boundary="=_alternative 00677A3F862571C7_="

This is a multipart message in MIME format.
--=_alternative 00677A3F862571C7_=
Content-Type: text/plain; charset="US-ASCII"

 Hi Olof,

  There are several reasons why an Ethernet driver should have an up to 
date version number:

1. Customers like to see they are really getting a new version.

2. It makes it easier for support personnel (me in this case) to see which 
driver they have. Sure, sometimes I can talk them thru doing a "sum" on 
the .ko and all that, but why not just use the version number? That's what 
it is for. And no, you can't just assume they have the version that came 
with the kernel they are running. It doesn't work that way.

3. It makes bug reporting easier. 

4. I have already run into too many problems and wasted too much time 
working with drivers when the number was NOT getting updated. 



Jim Lewis
Advisory Software Engineer
IBM Linux Technology Center
512-838-7754






Olof Johansson <olof@lixom.net> 
08/11/2006 01:00 PM

To
Linas Vepstas <linas@austin.ibm.com>
cc
netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
linuxppc-dev@ozlabs.org, Jens Osterkamp <Jens.Osterkamp@de.ibm.com>, James 
K Lewis/Austin/IBM@ibmus, Arnd Bergmann <arnd@arndb.de>
Subject
Re: [PATCH 4/4]: powerpc/cell spidernet ethtool -i version number info.






On Fri, Aug 11, 2006 at 12:11:17PM -0500, Linas Vepstas wrote:

> This patch adds version information as reported by 
> ethtool -i to the Spidernet driver.

Why does a driver that's in the mainline kernel need to have a version
number besides the kernel version?

I can understand it for drivers like e1000 that Intel maintain outside
of the kernel as well. But spidernet is a fully mainline maintained
driver, right?


-Olof


--=_alternative 00677A3F862571C7_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="sans-serif">&nbsp;Hi Olof,</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; There are several reasons why
an Ethernet driver should have an up to date version number:</font>
<br>
<br><font size=2 face="sans-serif">1. Customers like to see they are really
getting a new version.</font>
<br>
<br><font size=2 face="sans-serif">2. It makes it easier for support personnel
(me in this case) to see which driver they have. Sure, sometimes I can
talk them thru doing a &quot;sum&quot; on the .ko and all that, but why
not just use the version number? That's what it is for. And no, you can't
just assume they have the version that came with the kernel they are running.
It doesn't work that way.</font>
<br>
<br><font size=2 face="sans-serif">3. It makes bug reporting easier. </font>
<br>
<br><font size=2 face="sans-serif">4. I have already run into too many
problems and wasted too much time working with drivers when the number
was NOT getting updated. &nbsp;</font>
<br>
<br>
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
<td width=40%><font size=1 face="sans-serif"><b>Olof Johansson &lt;olof@lixom.net&gt;</b>
</font>
<p><font size=1 face="sans-serif">08/11/2006 01:00 PM</font>
<td width=59%>
<table width=100%>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">To</font></div>
<td><font size=1 face="sans-serif">Linas Vepstas &lt;linas@austin.ibm.com&gt;</font>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">cc</font></div>
<td><font size=1 face="sans-serif">netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
linuxppc-dev@ozlabs.org, Jens Osterkamp &lt;Jens.Osterkamp@de.ibm.com&gt;,
James K Lewis/Austin/IBM@ibmus, Arnd Bergmann &lt;arnd@arndb.de&gt;</font>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">Subject</font></div>
<td><font size=1 face="sans-serif">Re: [PATCH 4/4]: powerpc/cell spidernet
ethtool -i version number info.</font></table>
<br>
<table>
<tr valign=top>
<td>
<td></table>
<br></table>
<br>
<br>
<br><tt><font size=2>On Fri, Aug 11, 2006 at 12:11:17PM -0500, Linas Vepstas
wrote:<br>
<br>
&gt; This patch adds version information as reported by <br>
&gt; ethtool -i to the Spidernet driver.<br>
<br>
Why does a driver that's in the mainline kernel need to have a version<br>
number besides the kernel version?<br>
<br>
I can understand it for drivers like e1000 that Intel maintain outside<br>
of the kernel as well. But spidernet is a fully mainline maintained<br>
driver, right?<br>
<br>
<br>
-Olof<br>
</font></tt>
<br>
--=_alternative 00677A3F862571C7_=--

--===============1825548729==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1825548729==--
