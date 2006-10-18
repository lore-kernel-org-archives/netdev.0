From: Pavel Roskin <proski@gnu.org>
Subject: Re: d80211: ANNOUNCE: DadWifi,
	a port of MadWifi	to d80211
Date: Wed, 18 Oct 2006 00:26:00 -0400
Message-ID: <1161145560.2285.32.camel@portland>
References: <20061018001403.GA22990@devicescape.com>
	<20061017185116.1f14bd86@dads-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061017185116.1f14bd86@dads-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=madwifi-devel>
List-Post: <mailto:madwifi-devel@lists.sourceforge.net>
List-Help: <mailto:madwifi-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: madwifi-devel-bounces@lists.sourceforge.net
Errors-To: madwifi-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello!

On Tue, 2006-10-17 at 18:51 -0700, Stephen Hemminger wrote:
> I would consider this a BAD thing. You are creating a derived work
> out of GPL and non-GPL software. This actually will hurt the possible acceptance
> of the d80211 stack into the mainline kernel.

On the contrary, I think this effort with spur interest in d80211,
Atheros hardware and stimulate development of OpenHAL.  It will also put
additional pressure on Atheros to open HAL sources.

The technical ability of d80211 to handle a popular chipset would hardly
undermine its chances to be included into the kernel.  It takes more
that one step to achieve free in-kernel support for Atheros chipsets.
DadWifi may be one of those steps, OpenHAL or open-sourcing the Atheros
HAL would be the other.

If DadWifi succeeds at supplanting MadWifi, it will reduce the
proliferation of incompatible 802.11 stacks for Linux.  The FreeBSD
stack included in MadWifi will become obsolete.

There are many great ideas involving meshing networks that require
support at the 802.11 MAC layer because they are tied to the WDS
implementation.  Those efforts can be shared if the MAC layer is shared.
A company doing mesh networking on Atheros today could switch to
Broadcom tomorrow if Broadcom makes better chips, or vice versa.  
Users of DadWifi would contribute fixes that would affect users of other
chipsets.

Should d80211 be merged with the existing 802.11 stack in the kernel,
users of DadWifi would be among the testers, and they will ensure that
useful features of d80211 are not lost.

Unless I'm missing something obvious, I don't see absolutely anything
that could harm the chances of d80211 to make it to the mainline
kernel.

-- 
Regards,
Pavel Roskin

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
