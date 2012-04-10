From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH 0/2] adding tracepoints to vhost
Date: Tue, 10 Apr 2012 12:40:50 +0100
Message-ID: <CAJSP0QWA1z6_YQe9hhpG7bCyZQarmU5NXbHsLGTL_zPTk3dOUA@mail.gmail.com>
References: <20120410025327.49693.93562.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120410025327.49693.93562.stgit@amd-6168-8-1.englab.nay.redhat.com>
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

On Tue, Apr 10, 2012 at 3:58 AM, Jason Wang <jasowang@redhat.com> wrote:
> To help in vhost analyzing, the following series adding basic tracepoints=
 to
> vhost. Operations of both virtqueues and vhost works were traced in curre=
nt
> implementation, net code were untouched. A top-like satistics displaying =
script
> were introduced to help the troubleshooting.
>
> TODO:
> - net specific tracepoints?
>
> ---
>
> Jason Wang (2):
> =A0 =A0 =A0vhost: basic tracepoints
> =A0 =A0 =A0tools: virtio: add a top-like utility for displaying vhost sat=
istics
>
>
> =A0drivers/vhost/trace.h =A0 | =A0153 ++++++++++++++++++++
> =A0drivers/vhost/vhost.c =A0 | =A0 17 ++
> =A0tools/virtio/vhost_stat | =A0360 +++++++++++++++++++++++++++++++++++++=
++++++++++
> =A03 files changed, 528 insertions(+), 2 deletions(-)
> =A0create mode 100644 drivers/vhost/trace.h
> =A0create mode 100755 tools/virtio/vhost_stat

Perhaps this can replace the vhost log feature?  I'm not sure if
tracepoints support the right data types but it seems like vhost
debugging could be done using tracing with less code.

Stefan
