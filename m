From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH 19/25] mlx4: Randomizing mac addresses for slaves
Date: Fri, 6 Nov 2009 18:07:46 +1100
Message-ID: <20091106070736.GA12697@verge.net.au>
References: <4AF19E69.8070605@mellanox.co.il>
 <adar5seys3e.fsf@cisco.com>
 <15ddcffd0911041333l165ee274mfae3508a3db755e7@mail.gmail.com>
 <2ED289D4E09FBD4D92D911E869B97FDD0166CA59@mtlexch01.mtl.com>
 <adabpjhc6az.fsf@roland-alpha.cisco.com>
 <20091106040624.GA6629@verge.net.au>
 <adaeiocyykl.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tziporet Koren <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <adaeiocyykl.fsf-BjVyx320WGW9gfZ95n9DRSW4+XlvGpQz@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 05, 2009 at 10:08:58PM -0800, Roland Dreier wrote:
> 
>  > > igb uses the full output of random_ether_addr().  I'd be fine with
>  > > that.  However setting the OUI means you only get 24 bits of randomness
>  > > which makes a collision a lot more likely.
>  > 
>  > IIRC that was precisely why the OUI isn't used for the igb driver.
>  > 
>  > Perhaps some infrastructure (by which I mean a random_mac() function)
>  > is warranted so at least this discussion can be concentrated around that
>  > rather than repeating it for each driver that needs random mac addresses.
> 
> What would be the difference between random_mac() and the existing
> random_ether_addr() function?

Sorry, I was mistaken. igb is using random_ether_addr(),
which is what I had in mind.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
