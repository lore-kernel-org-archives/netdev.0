From: Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-01-12
Date: Mon, 12 Jan 2009 21:31:17 -0800
Message-ID: <1231824677.5405.17.camel@brick>
References: <20090112201302.GB3786@tuxdriver.com>
	 <20090112.212345.259792227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090112.212345.259792227.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-01-12 at 21:23 -0800, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Mon, 12 Jan 2009 15:13:02 -0500
> 
> > Please let me know if there are problems!
> 
> There's something funny in this tree.   In changeset
> 19f0a391bf9d88307e52557ff3125b24e2519bd4 there is
> a removal of arch/arm/mach-integrator/clock.h
> 
> I think when you installed that commit something
> automatically deleted zero length files it found,
> but that's just a guess.

make clean will assume empty files should be deleted.

Harvey

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
