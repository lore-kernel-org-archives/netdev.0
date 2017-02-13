From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: [PATCH net-next 0/3] bridge: minor fdb cleanup
Date: Mon, 13 Feb 2017 14:59:08 +0100
Message-ID: <1486994351-1137-1-git-send-email-nikolay@cumulusnetworks.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net
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
These patches aim to simplify the bridge fdb API a little by removing some
redundant functions and converting them into wrappers of a single function.
Also add proper lock checking to avoid future mistakes for the search
functions.

Thanks,
 Nik

Nikolay Aleksandrov (3):
  bridge: fdb: converge fdb searching functions into one
  bridge: fdb: add proper lock checks in searching functions
  bridge: fdb: converge fdb_delete_by functions into one

 net/bridge/br_device.c  |   2 +-
 net/bridge/br_fdb.c     | 177 ++++++++++++++++++------------------------------
 net/bridge/br_input.c   |   4 +-
 net/bridge/br_private.h |  14 +++-
 4 files changed, 81 insertions(+), 116 deletions(-)

-- 
2.1.4
