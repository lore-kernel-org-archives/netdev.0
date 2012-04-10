From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 0/2] adding tracepoints to vhost
Date: Tue, 10 Apr 2012 21:10:48 +0800
Message-ID: <CAEH94Li0==w=AUKd5WCPMcqxLh=+N6bKttOwrE8y-xuOyPt_QA@mail.gmail.com>
References: <20120410025327.49693.93562.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<CAJSP0QWA1z6_YQe9hhpG7bCyZQarmU5NXbHsLGTL_zPTk3dOUA@mail.gmail.com>
	<20120410124250.GB29808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120410124250.GB29808@redhat.com>
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

On Tue, Apr 10, 2012 at 8:42 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Tue, Apr 10, 2012 at 12:40:50PM +0100, Stefan Hajnoczi wrote:
>> On Tue, Apr 10, 2012 at 3:58 AM, Jason Wang <jasowang@redhat.com> wrote:
>> > To help in vhost analyzing, the following series adding basic tracepoi=
nts to
>> > vhost. Operations of both virtqueues and vhost works were traced in cu=
rrent
>> > implementation, net code were untouched. A top-like satistics displayi=
ng script
>> > were introduced to help the troubleshooting.
>> >
>> > TODO:
>> > - net specific tracepoints?
>> >
>> > ---
>> >
>> > Jason Wang (2):
>> > =A0 =A0 =A0vhost: basic tracepoints
>> > =A0 =A0 =A0tools: virtio: add a top-like utility for displaying vhost =
satistics
>> >
>> >
>> > =A0drivers/vhost/trace.h =A0 | =A0153 ++++++++++++++++++++
>> > =A0drivers/vhost/vhost.c =A0 | =A0 17 ++
>> > =A0tools/virtio/vhost_stat | =A0360 ++++++++++++++++++++++++++++++++++=
+++++++++++++
>> > =A03 files changed, 528 insertions(+), 2 deletions(-)
>> > =A0create mode 100644 drivers/vhost/trace.h
>> > =A0create mode 100755 tools/virtio/vhost_stat
>>
>> Perhaps this can replace the vhost log feature? =A0I'm not sure if
>> tracepoints support the right data types but it seems like vhost
>> debugging could be done using tracing with less code.
>>
>> Stefan
>
> vhost log is not a debugging tool, it logs memory accesses for
> migration.
Great, it is very appreciated if there's some docs about this

> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization



-- =

Regards,

Zhi Yong Wu
