From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] bridge: multicast: temp and perm
	entries behaviour enhancements
Date: Wed, 15 Jul 2015 07:16:49 -0700
Message-ID: <1436969811-13237-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: herbert@gondor.apana.org.au,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi,
Patch 01 adds a notify when a group is deleted via br_multicast_del_pg()
(on expire, on device delete or on device down).
Patch 02 changes how bridge device and bridge port delete and down/up are
handled. Until now on bridge down all groups were flushed, now only the
temp ones are (same for port), perm entries are flushed only on port or
bridge removal.

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (2):
  bridge: multicast: notify on group delete
  bridge: multicast: fix handling of temp and perm entries

 net/bridge/br_if.c        |  1 +
 net/bridge/br_multicast.c | 29 ++++++++++++++++++++++-------
 net/bridge/br_private.h   |  1 +
 3 files changed, 24 insertions(+), 7 deletions(-)

-- 
1.9.3
