From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 2/2] tun: remove useless codes in tun_chr_aio_read() and tun_recvmsg()
Date: Wed, 11 Dec 2013 11:14:04 +0800
Message-ID: <CAEH94Li+9tNP_U-og7oSyez4stqUTJ6xGCPaCmTSkyNZsRTT7w@mail.gmail.com>
References: <1386363300-19040-2-git-send-email-zwu.kernel@gmail.com>
	<20131209.203646.425478975392590777.davem@davemloft.net>
	<52A74CD1.808@gmail.com>
	<20131210.140036.1328560146971385473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel mlist <linux-kernel@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131210.140036.1328560146971385473.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only one reminder, since David has committed the two patches, you
maybe need to take their impact on your patches into account.

On Wed, Dec 11, 2013 at 3:00 AM, David Miller <davem@davemloft.net> wrote:
> From: Vlad Yasevich <vyasevich@gmail.com>
> Date: Tue, 10 Dec 2013 12:18:09 -0500
>
>> On 12/09/2013 08:36 PM, David Miller wrote:
>>> From: Zhi Yong Wu <zwu.kernel@gmail.com>
>>> Date: Sat,  7 Dec 2013 04:55:00 +0800
>>>
>>>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>>>
>>>> By checking related codes, it is impossible that ret > len or total_len,
>>>> so we should remove some useless codes in both above functions.
>>>>
>>>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>>
>>> Applied.
>>
>> Wait a sec.  We want to be able to return a value bigger then len
>> to trigger a MSG_TRUNC.  Jason has patches for to fix this.  If you
>> apply this, we'll have to re-introduce this code back in.
>>
>> Same goes for patch 1/2.
>
> That's fine, right now the code makes no sense as the condition can
> never be triggered so there is no harm removing the illogical code
> meanwhile.



-- 
Regards,

Zhi Yong Wu
