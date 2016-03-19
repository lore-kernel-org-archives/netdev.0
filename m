From: Parav Pandit <pandit.parav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/4] infiniband: hns: add Hisilicon RoCE support(driver code)
Date: Sat, 19 Mar 2016 19:54:57 +0530
Message-ID: <CAG53R5WnJvqTO9=V15gMeN9vbOeP9Gv2JOWb11AEk+pnHjktsg@mail.gmail.com>
References: <CAG53R5WfQR1jJUOi1fjY=oEgsK_EAxkA9SiDPV_KHLHsmqg0BQ@mail.gmail.com>
	<56E65EFC.3030109@huawei.com>
	<CAG53R5UTc8xF4TdRJm3ASv6PQ-JxhW7vDgXpFtYqX2tz_58UeA@mail.gmail.com>
	<56ED37C0.6090907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Wei Hu(Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56ED37C0.6090907-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 19, 2016 at 4:58 PM, oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
> On 2016/3/15 2:20, Parav Pandit wrote:
>>>>
>>>> Since SRQ is not supported in this driver version, can you keep
>>>> remaining code base also to not bother about SRQ specifically
>>>> poll_cq_one, modify_qp, destroy_qp etc?
>>>> SRQ support can come as complete additional patch along with cmd_mask,
>>>> callbacks and rest of the code.
>>>>
>>>> .
>>> Sorry, I see your review in time.
>>> Sure, SRQ is not supported in current roce driver. I have verified the function
>>> for RDMA. It is not influence. For your question, we need to analyse it scientific.
>>> after that, i will reply your doubt, is that ok?
>>
>> Yes. No problem.
>>
>> .
>>
> Hi, Parav Pandit
>     I have analyse and discuss with your reviewing. I considered that the srq is only the
> condition branch in verbs and without independent function, so reserved it.I have delete the relative
> function with srq independently.
>     if delete the branch operation with srq, it feel be inconvenient to understand
>

o.k. If I understand correctly, new patch will be without srq functionality.
If thats the case, that makes review and maintainability easier.
Thanks.
Parav
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
