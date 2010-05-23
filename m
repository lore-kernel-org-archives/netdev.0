From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH 0/7] ISDN patches for 2.6.35
Date: Sun, 23 May 2010 02:24:12 +0200 (CEST)
Message-ID: <20100522-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>,
        Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/options/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper/>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

Karsten, David,

following are seven patches to the CAPI subsystem and the Gigaset
driver I'd like to see included in kernel release 2.6.35.
The first three respond to user reports about an observed hang of
the userspace command "capiinit stop".
The others are cleanups from the ongoing driver development.

Thanks,
Tilman

Tilman Schmidt (7):
  Documentation/isdn: CAPI controller interface amendment
  isdn/capi: make reset_ctr op truly optional
  isdn/gigaset: remove dummy CAPI method implementations
  isdn/gigaset: adjust usb_gigaset tty write buffer limit
  isdn/gigaset: avoid copying AT commands twice
  isdn/gigaset: ignore irrelevant device responses
  isdn/gigaset: drop obsolete FIXME comment

 Documentation/isdn/INTERFACE.CAPI  |    8 +-
 drivers/isdn/capi/kcapi.c          |    6 +
 drivers/isdn/gigaset/bas-gigaset.c |   51 ++-----------
 drivers/isdn/gigaset/capi.c        |   28 -------
 drivers/isdn/gigaset/common.c      |    2 
 drivers/isdn/gigaset/ev-layer.c    |  142 ++++++++++++-------------------------
 drivers/isdn/gigaset/gigaset.h     |    9 --
 drivers/isdn/gigaset/interface.c   |   36 +++++++--
 drivers/isdn/gigaset/ser-gigaset.c |   27 +------
 drivers/isdn/gigaset/usb-gigaset.c |   29 +------
 10 files changed, 117 insertions(+), 221 deletions(-)
