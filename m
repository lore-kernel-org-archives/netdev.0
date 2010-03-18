From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL] vhost-net fixes for issues in 2.6.34-rc1
Date: Thu, 18 Mar 2010 11:53:55 +0200
Message-ID: <20100318095355.GA24194@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: samudrala@us.ibm.com, kvm@vger.kernel.org,
        Juan Quintela <quintela@redhat.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Laurent Chavey <chavey@google.com>,
        virtualization@lists.osdl.org,
        Unai Uribarri <unai.uribarri@optenet.com>,
        Jeff Dike <jdike@linux.intel.com>, Jiri Slaby <jirislaby@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

David,
The following tree includes patches fixing issues with vhost-net in
2.6.34-rc1.  Please pull them for 2.6.34.
 
Thanks!

The following changes since commit a3d3203e4bb40f253b1541e310dc0f9305be7c84:

  Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel/git/lenb/linux-acpi-2.6 (2010-03-14 20:29:21 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost

Jeff Dike (1):
      vhost: fix error path in vhost_net_set_backend

Michael S. Tsirkin (2):
      vhost: fix interrupt mitigation with raw sockets
      vhost: fix error handling in vring ioctls

 drivers/vhost/net.c   |   10 ++++++----
 drivers/vhost/vhost.c |   18 ++++++++++++------
 2 files changed, 18 insertions(+), 10 deletions(-)
