From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [V2 PATCH 1/1] ixgbe: force to synchronize
 reporting "link on" and
Date: Thu, 24 Dec 2015 13:10:57 +0800
Message-ID: <567B7E61.3070207@gmail.com>
References: <1450868046.3316.11.camel@intel.com>
	<1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3984763216682456650=="
Cc: venkat.viswanathan@windriver.com, Boris.Shteinbock@windriver.com,
	Vincent.Bourg@windriver.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============3984763216682456650==
Content-Type: multipart/alternative;
	boundary="------------010701050304000306010104"

This is a multi-part message in MIME format.
--------------010701050304000306010104
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 12/24/2015 11:12 AM, zyjzyj2000@gmail.com wrote:
> Hi, Jeff
>
> Thanks for your reply.
>
> Changes:
> Since there is a time span between link_up and link_speed to X540 NIC, it is not appropriate to continue in the function ixgbe_watchdog_link_is_up if only link_up is ready.
>
> Best Regards!
> Zhu Yanjun
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Hi, Jeff

The following logs are from the customer.  From these logs, there is a 
time span between link_up and link_speed.
This time span sometimes will make bonding in 802.3ad mode not work well.

What I have done in the patch is to prevent this time span in the ixgbe 
driver.

Best Regards!
Zhu Yanjun

Settings for eth0:
     Supported ports: [ TP ]
     Supported link modes:   100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Supported pause frame use: No
     Supports auto-negotiation: Yes
     Advertised link modes:  100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Advertised pause frame use: No
     Advertised auto-negotiation: Yes
     Speed: Unknown!
     Duplex: Unknown! (255)
     Port: Twisted Pair
     PHYAD: 0
     Transceiver: external
     Auto-negotiation: on
     MDI-X: Unknown
     Supports Wake-on: d
     Wake-on: d
     Current message level: 0x00000007 (7)
                    drv probe link
     Link detected: no
Settings for eth0:
     Supported ports: [ TP ]
     Supported link modes:   100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Supported pause frame use: No
     Supports auto-negotiation: Yes
     Advertised link modes:  100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Advertised pause frame use: No
     Advertised auto-negotiation: Yes
     Speed: Unknown!
     Duplex: Unknown! (255)
     Port: Twisted Pair
     PHYAD: 0
     Transceiver: external
     Auto-negotiation: on
     MDI-X: Unknown
     Supports Wake-on: d
     Wake-on: d
     Current message level: 0x00000007 (7)
                    drv probe link
     Link detected: yes
Settings for eth0:
     Supported ports: [ TP ]
     Supported link modes:   100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Supported pause frame use: No
     Supports auto-negotiation: Yes
     Advertised link modes:  100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Advertised pause frame use: No
     Advertised auto-negotiation: Yes
     Speed: Unknown!
     Duplex: Unknown! (255)
     Port: Twisted Pair
     PHYAD: 0
     Transceiver: external
     Auto-negotiation: on
     MDI-X: Unknown
     Supports Wake-on: d
     Wake-on: d
     Current message level: 0x00000007 (7)
                    drv probe link
     Link detected: yes
Settings for eth0:
     Supported ports: [ TP ]
     Supported link modes:   100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Supported pause frame use: No
     Supports auto-negotiation: Yes
     Advertised link modes:  100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Advertised pause frame use: No
     Advertised auto-negotiation: Yes
     Speed: Unknown!
     Duplex: Unknown! (255)
     Port: Twisted Pair
     PHYAD: 0
     Transceiver: external
     Auto-negotiation: on
     MDI-X: Unknown
     Supports Wake-on: d
     Wake-on: d
     Current message level: 0x00000007 (7)
                    drv probe link
     Link detected: yes
Settings for eth0:
     Supported ports: [ TP ]
     Supported link modes:   100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Supported pause frame use: No
     Supports auto-negotiation: Yes
     Advertised link modes:  100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Advertised pause frame use: No
     Advertised auto-negotiation: Yes
     Speed: Unknown!
     Duplex: Unknown! (255)
     Port: Twisted Pair
     PHYAD: 0
     Transceiver: external
     Auto-negotiation: on
     MDI-X: Unknown
     Supports Wake-on: d
     Wake-on: d
     Current message level: 0x00000007 (7)
                    drv probe link
     Link detected: yes
Settings for eth0:
     Supported ports: [ TP ]
     Supported link modes:   100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Supported pause frame use: No
     Supports auto-negotiation: Yes
     Advertised link modes:  100baseT/Full
                             1000baseT/Full
                             10000baseT/Full
     Advertised pause frame use: No
     Advertised auto-negotiation: Yes
     Speed: 10000Mb/s
     Duplex: Full
     Port: Twisted Pair
     PHYAD: 0
     Transceiver: external
     Auto-negotiation: on
     MDI-X: Unknown
     Supports Wake-on: d
     Wake-on: d
     Current message level: 0x00000007 (7)
                    drv probe link
     Link detected: yes

--------------010701050304000306010104--


--===============3984763216682456650==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------

--===============3984763216682456650==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3984763216682456650==--
