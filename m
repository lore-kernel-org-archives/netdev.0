From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: Is fallback vhost_net to =?utf-8?Q?qem?=
 =?utf-8?Q?u_for_live_migrate_available=EF=BC=9F?=
Date: Tue, 27 Aug 2013 10:41:52 +0100
Message-ID: <20130827094152.GA1625@zion.uk.xensource.com>
References: <521C1DCF.5090202@huawei.com>
 <20130827041935.GA7263@redhat.com>
 <521C4F96.8000103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>, <jasowang@redhat.com>,
	<kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	<qianhuibin@huawei.com>, <wangfuhai@huawei.com>,
	<wei.liu2@citrix.com>
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:6552 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238Ab3H0JwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 05:52:20 -0400
Content-Disposition: inline
In-Reply-To: <521C4F96.8000103@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46irst of all, good job, Chuanyu. :-)

On Tue, Aug 27, 2013 at 03:04:54PM +0800, Qin Chuanyu wrote:
[...]
> >.
> >
> Thanks for your reply.
>=20
> In fact=EF=BC=8CI am not sure that whether vhost_log could work on Xe=
n live
> migrate or not. Yes=EF=BC=8Cvhost_sync_dirty_bitmap work well on Kvm=EF=
=BC=8Cbut
> vhost_net havn't run on Xen before=EF=BC=8Calthough the method
> vhost_dev_sync_region -> memory_region_set_dirty ->
> xen_modified_memory call sequence exist.
>=20

=46or Xen-specific questions you might have better luck posting to
xen-devel@lists.xenproject.org.

And I think this project is interesting enough and of benificial to Xen
community as well. Could you CC Xen-devel@ for future updates?

Thanks
Wei.

> Have you considered the scene that vhost_migration_log code running
> on Xen=EF=BC=9F If yes=EF=BC=8Cit sames much easier then fallback dat=
apath from
> vhost_net to qemu for live migrate.
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
