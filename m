From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH net-next 02/11] net: Introduce new api for walking upper
 and lower devices
Date: Mon, 17 Oct 2016 18:42:14 -0600
Message-ID: <f2eee17c-835c-b14e-6c96-4fd8fb7d18c9@cumulusnetworks.com>
References: <1476494931-31813-1-git-send-email-dsa@cumulusnetworks.com>
 <1476494931-31813-3-git-send-email-dsa@cumulusnetworks.com>
 <20161017052121.2322279d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161017052121.2322279d@xeon-e3>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/17/16 6:21 AM, Stephen Hemminger wrote:
> 
> No if/else needed. No cast of void * ptr need. Use const if possible?
> 

so much of the stack does not use const and trying to add it for this API does not work -- the upper or lower device is passed to the callbacks and those callbacks invoke other apis. e.g., the bond patch calls vlan_get_encap_level, bond_verify_device_path and bond_confirm_addr and none of those accept a const dev.

v3 coming up with the more succinct versions, but const is not possible.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
