From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH] SIW: Module initialization
Date: Wed, 6 Oct 2010 18:06:52 +0200
Message-ID: <AANLkTikL6u4Kzd1jibp77GMZfMebxusoDX39dPsNK3RW@mail.gmail.com>
References: <1286261640-5121-1-git-send-email-bmt@zurich.ibm.com>
 <AANLkTik5=i+A5_OpU0rVyfYi=ibgS9UWMu82vMCmM=PN@mail.gmail.com> <20101006070242.3ca5a6d9@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101006070242.3ca5a6d9@s6510>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 6, 2010 at 12:02 AM, Stephen Hemminger
<shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, 5 Oct 2010 12:57:21 +0200
> Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org> wrote:
>
>> > + * TODO: Dynamic device management (network device registration/removal).
>>
>> The current implementation is such that one siw device is created for
>> each network device found at kernel module load time. That means that
>> you force the user to load the siw kernel module after all other
>> kernel modules that register a network device. I'm not sure that's a
>> good idea.
>
> Then device should be controlled by a netlink (rtnl_link_ops) style
> interface see vlan_netlink.c. Using netlink is extensible and provides
> a cleaner interface than all these other parameterization methods.

That will be a lot more work to implement than what Jason proposed:
adding a sysfs variable per Ethernet driver, e.g.
/sys/class/net/eth0/enable_iwarp.

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
