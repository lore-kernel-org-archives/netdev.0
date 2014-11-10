From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: e100: Laptop battery drain and WoL settings from
	EEPROM
Date: Mon, 10 Nov 2014 09:14:38 +0100
Message-ID: <201411100914.38486.linux@rainbow-software.org>
References: <201411090015.41446.linux@rainbow-software.org>
	<201411091918.04036.linux@rainbow-software.org>
	<20141109233437.GA5037@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20141109233437.GA5037@electric-eye.fr.zoreil.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Monday 10 November 2014, Francois Romieu wrote:
> Ondrej Zary <linux@rainbow-software.org> :
> [...]
>
> > > Looks like this laptop is probably WoL-capable even on battery.
> > >
> > > Measured the current from AC adapter:
> > > around 20mA with WoL inactive (shut down from Windows or by power
> > > button in GRUB) around 40mA with WoL active (shut down from Linux)
> > >
> > > So to work-around this problem, users must disable WoL manually on each
> > > boot.
>
> Or configure udev so that ethtool disables WoL.

This is inconsistent with other (non-Intel) ethernet drivers where users need 
to use ethtool only if they want to enable WoL.
Installing ethtool and writing udev rules just to make a laptop shutdown 
properly is not very user-friendly.

> The current policy has been here for ages. Some users may rely on it.
>
> There must be some strong rationale for their setup to have to be changed.

Yes, that might be a problem.

-- 
Ondrej Zary

------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
