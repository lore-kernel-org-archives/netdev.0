From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 0/3] vhost: cross-endian code cleanup
Date: Tue, 16 Feb 2016 17:34:13 +0200
Message-ID: <20160216153413.GA32554@redhat.com>
References: <20160216145418.7448.71329.stgit@bahia.lab.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Greg Kurz <gkurz@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160216145418.7448.71329.stgit@bahia.lab.toulouse-stg.fr.ibm.com>
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

On Tue, Feb 16, 2016 at 03:54:18PM +0100, Greg Kurz wrote:
> This series is a new tentative to have cleaner cross-endian code.
> 
> Patches 1/3 is new: it fixes a side-effect in case vhost_init_used() fails.
> 
> Patch 2/3 comes from v1: it renames cross-endian helpers
> 
> Patch 3/3 is new: it simply renames vhost_init_used() as suggested by Michael.

Is this on top of my tree?

> ---
> 
> Greg Kurz (3):
>       vhost: fix error path in vhost_init_used()
>       vhost: rename cross-endian helpers
>       vhost: rename vhost_init_used()
> 
> 
>  drivers/vhost/net.c   |    2 +-
>  drivers/vhost/scsi.c  |    2 +-
>  drivers/vhost/test.c  |    2 +-
>  drivers/vhost/vhost.c |   49 +++++++++++++++++++++++++++++++++++++------------
>  drivers/vhost/vhost.h |    2 +-
>  5 files changed, 41 insertions(+), 16 deletions(-)
