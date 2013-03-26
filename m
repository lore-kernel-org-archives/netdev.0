From: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
Subject: ieee802154: Source addr fix for dgram and some
	small at86rf230 driver enhancements
Date: Tue, 26 Mar 2013 22:41:28 +0000
Message-ID: <1364337691-20163-1-git-send-email-stefan@datenfreihafen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

Second version. Changes since version 1:
- Obey 80 chars rules
- Switch logging mode to vdbg to avoid noise
- Remove uneeded might_sleep()

Thanks Alan, Werner and Alex for the feedback.

I feel these are ready so I added DaveM and netdev to pick them up if they think
the same.

[PATCH 1/3] ieee802154/dgram: Pass source address in dgram_recvmsg

Patch from Stephen to fix the ieee802154 stack to actually put in the source
address in datagrams. This allows using recvfrom() from userspace. This is a
long standing bug. Actually I think it never worked. :)

[PATCH 2/3] ieee802154/at86rf230: Implement hardware address filter

Allows the to filter frames directly in the transceiver hardware. Useful for
normal operation mode and mandatory for automatic ACK and automatic retransmits.

[PATCH 3/3] ieee802154/at86rf230: Fix register names for RX_AACK_ON

Not needed right now but still a good idea to get in imho. Register names have
always been wrong but never used.

regards
Stefan Schmidt

------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
