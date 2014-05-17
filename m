From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v1 for-next 0/3] IB: Use GFP_NOIO calls in IPoIB connected
 mode TX path
Date: Sat, 17 May 2014 23:52:10 +0300
Message-ID: <CAJZOPZJVxF6A-3s16feqoWCb5gOLTjyUmB3F+st1+1QWp+bJnQ@mail.gmail.com>
References: <1399810512-30774-1-git-send-email-ogerlitz@mellanox.com>
	<alpine.LNX.2.00.1405131338030.16459@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.00.1405131338030.16459-ztGlSCb7Y1iN3ZZ/Hiejyg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 13, 2014 at 2:38 PM, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org> wrote:
> On Sun, 11 May 2014, Or Gerlitz wrote:

>> This series is a refactored form of the one posted by Jiri Kosina
>> to LKML and netdev according to the discussion that followed
>> and the guidelines you provided here https://lkml.org/lkml/2014/3/5/250

>> Basically, the functionality changes introduced by this series fully
>> reside on the IB side of things, so I am only posting the actual patches
>> to linux-rdma with CC on the cover-letter to the lists that were on V0.

> Thanks, I am fine with my Signoff on that.
> Roland, is this going to be merged by you, or should this go to DaveM directly?

Roland, we're soon on -rc6 and there's no reason for this to miss
3.16, could you please comment whether you want it to go through your
tree or net-next?

> Jiri Kosina
> SUSE Labs
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
