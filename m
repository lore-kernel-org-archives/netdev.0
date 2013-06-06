From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net 0/2] vhost fixes for 3.10
Date: Thu, 6 Jun 2013 15:20:29 +0300
Message-ID: <1370521145-9723-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tommi Rantala <tt.rantala@gmail.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Two patches fixing the fallout from the vhost cleanup in 3.10.
Thanks to Tommi Rantala who reported the issue.

Tommi, could you please confirm this fixes the crashes for you?

Michael S. Tsirkin (2):
  vhost: check owner before we overwrite ubuf_info
  vhost: fix ubuf_info cleanup

 drivers/vhost/net.c   | 26 +++++++++++---------------
 drivers/vhost/vhost.c |  8 +++++++-
 drivers/vhost/vhost.h |  1 +
 3 files changed, 19 insertions(+), 16 deletions(-)

-- 
MST
