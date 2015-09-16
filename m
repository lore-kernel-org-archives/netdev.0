From: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Wed, 16 Sep 2015 09:15:24 +0200
Message-ID: <87zj0mbzsj.fsf@free-electrons.com>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
	<1442386435.3756.282.camel@vitec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux\@arm.linux.org.uk" <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs\@vger.kernel.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"trond.myklebust\@primarydata.com" <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"anna.schumaker\@netapp.com" <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Damien =?utf-8?Q?Th=C3=A9bault?= <damien.thebault-RsgQwIhcE7EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1442386435.3756.282.camel-RsgQwIhcE7EAvxtiuMwx3w@public.gmane.org> ("Damien =?utf-8?Q?Th?=
 =?utf-8?Q?=C3=A9bault=22's?=
	message of "Wed, 16 Sep 2015 06:53:57 +0000")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Damien,
=20
 On mer., sept. 16 2015, Damien Th=C3=A9bault <damien.thebault-RsgQwIhcE7E@public.gmane.org=
m> wrote:

> On Fri, 2015-09-11 at 12:38 +0100, Russell King - ARM Linux wrote:
>> I have a recent Marvell Armada 388 board here which uses the mvneta
>> driver.  I'm seeing some weird effects with NFS with it acting as a
>> client.
>
> Hello,
>
> I'm upgrading a Marvelle Armada 370 board using the mvneta driver fro=
m
> 4.0 to 4.2 and noticed issues with NFS booting.
> Basically, most of the time init returns with an error code, or
> programs segfault or throw illegal instructions.
>
> Since it worked fine on 4.0 I bisected until I found commit
> a84e32894191cfcbffa54180d78d7d4654d56c20 "net: mvneta: fix refilling
> for Rx DMA buffers".
>
> If I revert this commit, everything seems to get back to normal.
> Could you try it ? The two issues look very similar.

Actually there was a bug with this commit, but a fix had been submitted
and accepted yesterday, you can find him here:
https://patchwork.ozlabs.org/patch/518111/.

Thanks,

Gregory

>
> Regards

--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
