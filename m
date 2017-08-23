From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: Re: [PATCH 3/3] net: rsi: netlink: constify genl_ops
Date: Wed, 23 Aug 2017 15:35:11 +0530
Message-ID: <34315266-d6be-0c88-4d6e-129c1300e3f7@gmail.com>
References: <1503482375-19983-1-git-send-email-arvind.yadav.cs@gmail.com>
 <1503482375-19983-4-git-send-email-arvind.yadav.cs@gmail.com>
 <87378iy52u.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Larry.Finger@lwfinger.net,
        chaoming_li@realsil.com.cn, jon.maloy@ericsson.com,
        ying.xue@windriver.com, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87378iy52u.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


On Wednesday 23 August 2017 03:32 PM, Kalle Valo wrote:
> Arvind Yadav <arvind.yadav.cs@gmail.com> writes:
>
>> genl_ops are not supposed to change at runtime. All functions
>> working with genl_ops provided by <net/genetlink.h> work with
>> const genl_ops. So mark the non-const structs as const.
>>
>> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
>> ---
>>   net/tipc/netlink_compat.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
> Using the prefix "rsi:" looks wrong for this patch.
Thanks for pointing. I will update.
>
~arvind
