From: David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] net: add netlink_ext_ack support to
 rtnl_link_ops
Date: Sat, 24 Jun 2017 20:50:24 -0600
Message-ID: <1bfb7a80-a440-f960-1f35-a70542106cfb@gmail.com>
References: <01256ebba091f2108ebeff43e61305bb533067d4.1498303258.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        osmocom-net-gprs-qjLDD68F18N4m7O/Vxda39i2O/JbrIOy@public.gmane.org, linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, dmitry.tarnyagin-0TCahj4L2NoXWF+eFR7m5Q@public.gmane.org,
        wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
        laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
        dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, shm-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
        arvid.brodin-SVm98a2vdck@public.gmane.org, alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
        yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
        steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
        johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <01256ebba091f2108ebeff43e61305bb533067d4.1498303258.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 6/24/17 5:35 AM, Matthias Schiffer wrote:
> The following functions are extended with a netlink_ext_ack argument to
> allow extended error reporting:
> 
> * validate
> * newlink
> * changelink
> * slave_validate
> * slave_changelink

I would prefer separate patches for validate, slave_validate, newlink,
changelink, and slave_changelink. I do not believe there is a reason to
lump them into 1 giant patch.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
