From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH 5/5] initdev:kernel: USB and SCSI block init device
	notification, v3
Date: Fri, 5 Jun 2009 10:55:30 -0700
Message-ID: <20090605175529.GA18688@cuplxvomd02.corp.sa.net>
References: <20090502023000.GA16076@cuplxvomd02.corp.sa.net> <20090502115539.396206bc@linux-lm> <20090505001950.GC29124@cuplxvomd02.corp.sa.net> <d82e647a0905042105g7639fc84g736668c371c40053@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d82e647a0905042105g7639fc84g736668c371c40053@mail.gmail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 05, 2009 at 12:05:19AM -0400, Ming Lei wrote:
> 2009/5/5 David VomLehn <dvomlehn@cisco.com>:
> > On Fri, May 01, 2009 at 11:55:39PM -0400, Ming Lei wrote:
> >> On Fri, 1 May 2009 19:30:00 -0700
> >> David VomLehn <dvomlehn@cisco.com> wrote:
> >>
> >> > From: Alan Stern <stern@rowland.harvard.edu
> >> > diff --git a/drivers/scsi/scsi_scan.c b/drivers/scsi/scsi_scan.c
> >> > index 6f51ca4..735b061 100644
> >> > --- a/drivers/scsi/scsi_scan.c
> >> > +++ b/drivers/scsi/scsi_scan.c
> > ...
> >> > @@ -1834,6 +1834,7 @@ static int do_scan_async(void *_data)
> >> > =A0 =A0 struct async_scan_data *data =3D _data;
> >> > =A0 =A0 do_scsi_scan_host(data->shost);
> >> > =A0 =A0 scsi_finish_async_scan(data);
> >> > + =A0 initdev_probe_done(BOOTDEV_BLOCK_MASK);
> >>
> >> Which code are waiting for the block device's probe done?
> >
> > None yet. That remains to be done.
> >
>=20
> Would you mind submitting  the code path of waitting for probe done t=
o allow a
> intact review?  Without the waitting code, it is a a little difficult
> to undersand or verify
> your patch, IMHO.

This will be in the next spin of the patch, coming soon (possibly today=
).

> Thanks
> Lei Ming

David VomLehn
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
