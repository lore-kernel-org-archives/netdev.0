From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] vxlan: introduce vxlan_rdst_append
Date: Mon, 24 Jun 2013 01:28:59 -0700 (PDT)
Message-ID: <20130624.012859.37462047607376579.davem@davemloft.net>
References: <1372004543-24675-2-git-send-email-mike.rapoport@ravellosystems.com>
	<kq8nds$ao1$1@ger.gmane.org>
	<CAF1J0HPRunidGmHHCMrmDCH3GHNZvzXAmKSRHeVQwLpx-z6NTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: mike.rapoport@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab3FXI3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 04:29:03 -0400
In-Reply-To: <CAF1J0HPRunidGmHHCMrmDCH3GHNZvzXAmKSRHeVQwLpx-z6NTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Mon, 24 Jun 2013 09:54:51 +0300

> On Mon, Jun 24, 2013 at 9:02 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Sun, 23 Jun 2013 at 16:22 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>>> to allow remotes list management for both FDB entries and default
>>> destinations
>>>
>>> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
>>> ---
>>>  drivers/net/vxlan.c | 14 ++++++++++----
>>>  1 file changed, 10 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>>> index 212a256..e5fb6568 100644
>>> --- a/drivers/net/vxlan.c
>>> +++ b/drivers/net/vxlan.c
>>> @@ -386,14 +386,13 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
>>>       return f;
>>>  }
>>>
>>> -/* Add/update destinations for multicast */
>>> -static int vxlan_fdb_append(struct vxlan_fdb *f,
>>> +static int vxlan_rdst_append(struct list_head *remotes,
>>>                           __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
>>
>>
>> I think you need to align the above line.
> 
> I just kept the original indentation

When you change the arguments to a function, you are absolutely obligated
to fix the indentation of any surrounding lines.

In the networking code, functions are to be styled such that the arguments
appearing on the second and subsequent lines are aligned perfectly to the
first column after the openning parenthesis of the first line.

Therefore, if you change where that openning parenthesis is, you must
reindent the subsequent lines.
