From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: Re: [PATCH 3/3 v2] net: netlink: constify genl_ops
Date: Wed, 23 Aug 2017 15:54:05 +0530
Message-ID: <84dbca9a-8a08-1975-cf1f-93ee94b890ca@gmail.com>
References: <1503482923-21640-1-git-send-email-arvind.yadav.cs@gmail.com>
 <87y3qawpp1.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Larry.Finger@lwfinger.net,
        chaoming_li@realsil.com.cn, jon.maloy@ericsson.com,
        ying.xue@windriver.com, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y3qawpp1.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kalle,


On Wednesday 23 August 2017 03:50 PM, Kalle Valo wrote:
> Arvind Yadav <arvind.yadav.cs@gmail.com> writes:
>
>> genl_ops are not supposed to change at runtime. All functions
>> working with genl_ops provided by <net/genetlink.h> work with
>> const genl_ops. So mark the non-const structs as const.
>>
>> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
>> ---
>> Changes in v2:
>>               Patch Subject was wrong.
>>
>>   net/tipc/netlink_compat.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
> I don't think the title is still misleading. Other patches have used
> "tipc:", I think you should use the same:
Ok, I will update as per your suggestion.
>
> $ git log --oneline --no-merges -20 net/tipc
> 41c6d650f653 net: convert sock.sk_refcnt from atomic_t to refcount_t
> 343eba69c696 net: tipc: Fix a sleep-in-atomic bug in tipc_msg_reverse
> 844cf763fba6 tipc: make macro tipc_wait_for_cond() smp safe
> ec8a09fbbeff tipc: refactor function tipc_sk_recv_stream()
> e9f8b10101c6 tipc: refactor function tipc_sk_recvmsg()
> c1be7756284b tipc: close the connection if protocol messages contain errors
> 4e0df4951e9e tipc: improve error validations for sockets in CONNECTING state
> 42b531de17d2 tipc: Fix missing connection request handling
> 05ff8378975a tipc: fix socket flow control accounting error at tipc_recv_stream
> 3364d61c92ec tipc: fix socket flow control accounting error at tipc_send_stream
> 78302fd40576 tipc: check return value of nlmsg_new
> fe52145f91fe netlink: pass extended ACK struct where available
> fceb6435e852 netlink: pass extended ACK struct to parsing functions
> 66bc1e8d5d1d tipc: allow rdm/dgram socketpairs
> 70b03759e9ec tipc: add support for stream/seqpacket socketpairs
> 7efea60dcffc tipc: adjust the policy of holding subscription kref
> 139bb36f754a tipc: advance the time of deleting subscription from subscriber->subscrp_list
> 557d054c01da tipc: fix nametbl deadlock at tipc_nametbl_unsubscribe
> cdfbabfb2f0c net: Work around lockdep limitation in sockets that use sockets
> 174cd4b1e5fb sched/headers: Prepare to move signal wakeup & sigpending methods from <linux/sched.h> into <linux/sched/signal.h>
>
~arvind
