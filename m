From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND PATCH v7 00/21] Add HiSilicon RoCE driver
Date: Mon, 23 May 2016 09:06:22 +0800
Message-ID: <5742578E.5070601@huawei.com>
References: <1462849483-67927-1-git-send-email-oulijun@huawei.com>
 <ee4fe6df-e9b0-28da-c960-c288d6617025@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ee4fe6df-e9b0-28da-c960-c288d6617025-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi, Doug Ledford

We will modify the license description of the beginning of the code file 
in  patch v8.
Thanks

Regards
Wei Hu

On 2016/5/14 5:09, Doug Ledford wrote:
> On 05/09/2016 11:04 PM, Lijun Ou wrote:
>> The HiSilicon Network Substem is a long term evolution IP which is
>> supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
>> Sybsystem) also has a hardware support of performing RDMA with
>> RoCEE.
>> The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
>> will support mulitple versions of SOCs in future. This version of driver
>> is meant to support Hip06 SoC(which confirms to RoCEEv1 hardware
>> specifications).
>>
>> Changes v6 -> v7:
>> 1. modify some type of parameter, use bool replace the original type.
>> 2. add the Signed-off-by signatures in the first patch.
>> 3. delete the improper print sentence in hns_roce_create_eq.
> One thing you should be aware of (but which you may not care about,
> which is fine) is that if you want your driver to be available as part
> of the OpenFabric Alliances OFED distribution, the license on the files
> would need to be "GPL or BSD" (see the remainder of the RDMA stack for
> examples).  If you don't want that license on your files, I'm fine with
> that, and I won't hold up your submission based on the license.  If,
> however, you *do* want your code to be shipable as part of OFED, it is
> much easier to update the license on the files before you submit them
> and third parties modify them.  If you want to change the license later,
> you have to get every person that has made any substantive change to the
> file to agree to the license change.
>
>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
