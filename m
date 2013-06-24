From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next v4 1/2] vxlan: introduce vxlan_rdst_append
Date: Mon, 24 Jun 2013 09:54:51 +0300
Message-ID: <CAF1J0HPRunidGmHHCMrmDCH3GHNZvzXAmKSRHeVQwLpx-z6NTA@mail.gmail.com>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372004543-24675-2-git-send-email-mike.rapoport@ravellosystems.com>
	<kq8nds$ao1$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog103.obsmtp.com ([74.125.245.74]:59773 "HELO
	na3sys010aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752536Ab3FXGyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 02:54:53 -0400
Received: by mail-oa0-f52.google.com with SMTP id g12so11283697oah.39
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 23:54:52 -0700 (PDT)
In-Reply-To: <kq8nds$ao1$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 9:02 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, 23 Jun 2013 at 16:22 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>> to allow remotes list management for both FDB entries and default
>> destinations
>>
>> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
>> ---
>>  drivers/net/vxlan.c | 14 ++++++++++----
>>  1 file changed, 10 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 212a256..e5fb6568 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -386,14 +386,13 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
>>       return f;
>>  }
>>
>> -/* Add/update destinations for multicast */
>> -static int vxlan_fdb_append(struct vxlan_fdb *f,
>> +static int vxlan_rdst_append(struct list_head *remotes,
>>                           __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
>
>
> I think you need to align the above line.

I just kept the original indentation

>>
>> +/* Add/update destinations for multicast */
>> +static int vxlan_fdb_append(struct vxlan_fdb *f,
>> +                         __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
>
> You need to align this line too.

And here as well.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
Sincerely yours,
Mike.
