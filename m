From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/5] initdev:kernel: USB and SCSI block init device
	notification, v3
Date: Tue, 5 May 2009 12:05:19 +0800
Message-ID: <d82e647a0905042105g7639fc84g736668c371c40053@mail.gmail.com>
References: <20090502023000.GA16076@cuplxvomd02.corp.sa.net>
	 <20090502115539.396206bc@linux-lm>
	 <20090505001950.GC29124@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090505001950.GC29124-CFZJ1or75eBPWxJt6d6B6bQa8qPdvLwY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/5/5 David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>:
> On Fri, May 01, 2009 at 11:55:39PM -0400, Ming Lei wrote:
>> On Fri, 1 May 2009 19:30:00 -0700
>> David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org> wrote:
>>
>> > From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org
>> > diff --git a/drivers/scsi/scsi_scan.c b/drivers/scsi/scsi_scan.c
>> > index 6f51ca4..735b061 100644
>> > --- a/drivers/scsi/scsi_scan.c
>> > +++ b/drivers/scsi/scsi_scan.c
> ...
>> > @@ -1834,6 +1834,7 @@ static int do_scan_async(void *_data)
>> > =A0 =A0 struct async_scan_data *data =3D _data;
>> > =A0 =A0 do_scsi_scan_host(data->shost);
>> > =A0 =A0 scsi_finish_async_scan(data);
>> > + =A0 initdev_probe_done(BOOTDEV_BLOCK_MASK);
>>
>> Which code are waiting for the block device's probe done?
>
> None yet. That remains to be done.
>

Would you mind submitting  the code path of waitting for probe done to =
allow a
intact review?  Without the waitting code, it is a a little difficult
to undersand or verify
your patch, IMHO.

Thanks

--=20
Lei Ming
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
