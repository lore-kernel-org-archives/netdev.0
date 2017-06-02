From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [pull request][for-next 0/6] Mellanox mlx5 updates 2017-05-23
Date: Fri, 02 Jun 2017 12:08:39 -0400 (EDT)
Message-ID: <20170602.120839.1394660754953676217.davem@davemloft.net>
References: <1496357879.7171.76.camel@redhat.com>
        <20170602153940.GX5406@mtr-leonro.local>
        <20170602160641.ylowbobe5v72ui7g@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170602160641.ylowbobe5v72ui7g-+o4/htvd0TCa6kscz5V53/3mLCh9rsb+VpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 2 Jun 2017 09:06:43 -0700

> On Fri, Jun 02, 2017 at 06:39:40PM +0300, Leon Romanovsky wrote:
>> On Thu, Jun 01, 2017 at 06:57:59PM -0400, Doug Ledford wrote:
>> > On Thu, 2017-05-25 at 12:02 -0400, David Miller wrote:
>> > > From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> > > Date: Tue, 23 May 2017 14:43:58 +0300
>> > >
>> > > > Hi Dave and Doug,
>> > > > 
>> > > > This series introduces some small updates and FPGA support to the
>> > > mlx5
>> > > > core/ethernet and IB drivers.
>> > > > 
>> > > > For more details please see below.
>> > > > 
>> > > > Please pull and let me know if there's any problem.
>> > >
>> > > Ok, I've pulled this into net-next.
>> > >
>> > > Doug let me know if there are any merge hassles we need to coordinate
>> > > on.
>> > >
>> > > Thanks.
>> >
>> > Will do.  But is the question of a possible revert settled?  Because
>> > once I pull, a revert means I have to pull all the way up to the revert
>> > as well...
>> 
>> Revert is unlikely to happen, Saeed is working with Alexey to resolve
>> his raised concerns.
> 
> I still think the direction is absolutely wrong.
> Reinventing fpga interfaces via nic driver is no-go.
> mlx needs to send a patch to revert it to show that they are willing
> to listen to the community.

"Two people from Facebook" is not the commnity Alexei. :-)

And ironically, you guys will want to be one of the main users of
these facilities for the KTLS offload bits, so the desire to separate
it out and make "backports easier" really confuses me.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
