From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH for-next V1 0/2] mlx5_core: mlx5_ifc updates
Date: Fri, 15 Apr 2016 17:22:54 -0400 (EDT)
Message-ID: <20160415.172254.1148340547086083909.davem@davemloft.net>
References: <1460563864-22931-1-git-send-email-saeedm@mellanox.com>
	<CALzJLG__o56edSf__To-BM6jakuwP7zAAEEQH8LQNTKp-2LRDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG__o56edSf__To-BM6jakuwP7zAAEEQH8LQNTKp-2LRDQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Date: Fri, 15 Apr 2016 20:10:07 +0300

> On Wed, Apr 13, 2016 at 7:11 PM, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>> Hi Dave and Doug
>>
>> Changes form V0:
>>         - 2nd patch commit message fixes.
>>
>> This series include mlx5_core updates for both net-next and rdma
>> trees for 4.7 kernel cycle. This is the only shared code planned
>> for 4.7 between rdma and net trees. Hopefully, this will prevent
>> future conflicts when merging between ib-next and net-next once
>> 4.7 cycle is over and merge window is opened.
>>
>> Both Mellanox rdma and net submissions will proceed once this series
>> is applied into both trees.
>>
>> Future shared code will be sent to both maintainers as pull requests
>> from Mellanox's kernel.org tree.
>>
>> We have included all the maintainers of respective drivers.
>> Kindly review the change and let us know in case of any review comments.
>>
>> Saeed Mahameed (1):
>>   net/mlx5: Update mlx5_ifc hardware features
>>
>> Tariq Toukan (1):
>>   net/mlx5: Fix mlx5 ifc cmd_hca_cap bad offsets
>>
>>  include/linux/mlx5/mlx5_ifc.h |  253 +++++++++++++++++++++++++++++------------
>>  1 files changed, 179 insertions(+), 74 deletions(-)
>>
>> --
> 
> Hi Dave,
> 
> This series is still in "Changes Requested" state in patchwork, but
> there is nothing to change here.
> I will be glad if you give it a shot, it is blocking all of our mlx5
> activities for both net and rdma trees.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
