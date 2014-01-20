From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] tun: handle copy failure in tun_put_user()
Date: Mon, 20 Jan 2014 13:02:38 +0800
Message-ID: <52DCADEE.3020309@redhat.com>
References: <1390187808-5462-1-git-send-email-jasowang@redhat.com> <20140119.194856.491294439635992592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140119.194856.491294439635992592.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/20/2014 11:48 AM, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Mon, 20 Jan 2014 11:16:48 +0800
>
>> This patch return the error code of copy helpers in tun_put_user() instead of
>> ignoring them.
>>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> If you perform some of the copy successfully, you have to report that
> length rather than just an error.
>
> Otherwise userland has no way to determine how much of the data was
> successfully sourced.
>
> I'm not applying this, sorry.

Right, looks like we need more changes in tun to return the accurate
length copied in this case.
