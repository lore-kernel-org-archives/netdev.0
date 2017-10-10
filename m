From: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH net 2/2] net/smc: dev_put for netdev after usage of
 ib_query_gid()
Date: Tue, 10 Oct 2017 19:04:50 +0000
Message-ID: <VI1PR0502MB3008C19845C45D7D4A9147F9D1750@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <20171010141351.87700-1-ubraun@linux.vnet.ibm.com>
 <20171010141351.87700-3-ubraun@linux.vnet.ibm.com>
 <VI1PR0502MB30088E4F58036AB3A06822E8D1750@VI1PR0502MB3008.eurprd05.prod.outlook.com>
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
To: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <VI1PR0502MB30088E4F58036AB3A06822E8D1750-o1MPJYiShExKsLr+rGaxW8DSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> > For ROCEs ib_query_gid() takes a reference count on the net_device.
> > This reference count must be decreased by the caller.
> >
> > Signed-off-by: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Reported-by: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>=20
Also add 'Fixes' line that introduced this bug.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
