From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [RFC] [PATCH] net: socket: Fix the wrong returns for recvmsg and
 sendmsg
Date: Tue, 2 Jun 2015 11:15:22 +0100
Message-ID: <20150602101522.GA2623@ares>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
 <20150602012154.GB23370@kroah.com>
 <556D2B8C.9010108@huawei.com>
 <20150601.222357.122000161676177828.davem@davemloft.net>
 <20150602062751.GA3912@kroah.com>
 <556D50AA.4000005@huawei.com>
 <20150602065257.GA29335@1wt.eu>
 <556D55D5.6020303@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, lizefan@huawei.com,
	viro@zeniv.linux.org.uk, xuhanbing@huawei.com,
	stable@vger.kernel.org, netdev@vger.kernel.org,
	Kamal Mostafa <kamal@canonical.com>
To: Junling Zheng <zhengjunling@huawei.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <556D55D5.6020303@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 02, 2015 at 03:05:57PM +0800, Junling Zheng wrote:
> On 2015/6/2 14:52, Willy Tarreau wrote:
> > On Tue, Jun 02, 2015 at 02:43:54PM +0800, Junling Zheng wrote:
> >> On 2015/6/2 14:27, Greg KH wrote:
> >>> On Mon, Jun 01, 2015 at 10:23:57PM -0700, David Miller wrote:
> >>>> From: Junling Zheng <zhengjunling@huawei.com>
> >>>> Date: Tue, 2 Jun 2015 12:05:32 +0800
> >>>>
> >>>>> So, the problem commit is 281c9c36 (net: compat: Update
> >>>>> get_compat_msghdr() to match copy_msghdr_from_user() behaviour)=
,
> >>>>> which fixes db31c55a6fb2 and brings the get_compat_msghdr() in =
line
> >>>>> with copy_msghdr_from_user().
> >>>>
> >>>> Upstream this got fixed by:
> >>>>
> >>>> 08adb7dabd4874cc5666b4490653b26534702ce0
> >>>>
> >>>> So the part that makes us not unconditionally return -EFAULT nee=
ds
> >>>> to be backported, and that's probably equivalent to the patch
> >>>> your proposed which therefore should be applied.
> >>>
> >>> Ok, thanks, now applied.
> >>>
> >>
> >> Maybe other stable version also needs this fix:)
> >=20
> > Yes, from what I'm seeing, at least 3.2 and 2.6.32 need it as well.
> >=20
>=20
> Yeah, all other stable versions *except 3.19 and 4.0* may need this f=
ix:)

This seems to be correct.  I am queuing this fix for the 3.16 kernel
as well.  Thank you!

Cheers,
--
Lu=EDs
