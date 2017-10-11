From: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH v2 net 1/2] net/smc: replace function pointer get_netdev()
Date: Wed, 11 Oct 2017 14:41:12 +0000
Message-ID: <VI1PR0502MB300809A84CC9FF9094DB8329D14A0@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <20171011114723.30733-1-ubraun@linux.vnet.ibm.com>
 <20171011114723.30733-2-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org" <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        "heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org" <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        "raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171011114723.30733-2-ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Ursula Braun [mailto:ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org]
> Sent: Wednesday, October 11, 2017 6:47 AM
> To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org; schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org;
> heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org; raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org;
> ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org; Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Subject: [PATCH v2 net 1/2] net/smc: replace function pointer get_netdev(=
)
>=20
> SMC should not open code the function pointer get_netdev of the IB device=
.
> Replacing ib_query_gid(..., NULL) with ib_query_gid(..., gid_attr) allows=
 access
> to the netdev.
>=20
> Signed-off-by: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Suggested-by: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Reviewed-by: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Looks fine.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
