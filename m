From: Zefan Li <lizefan@huawei.com>
Subject: Re: [3.4 PATCH] Bluetooth: Fix invalid length check in l2cap_information_rsp()
Date: Thu, 9 Apr 2015 09:08:43 +0800
Message-ID: <5525D11B.3010601@huawei.com>
References: <1427707657-28545-1-git-send-email-tim.niemeyer@corscience.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <stable@vger.kernel.org>,
	Jaganath Kanakkassery <jaganath.k@samsung.com>,
	Chan-Yeol Park <chanyeol.park@samsung.com>,
	Gustavo Padovan <gustavo.padovan@collabora.co.uk>,
	Jianguo Wu <wujianguo@huawei.com>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-bluetooth@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Tim Niemeyer <tim.niemeyer@corscience.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427707657-28545-1-git-send-email-tim.niemeyer@corscience.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/3/30 17:27, Tim Niemeyer wrote:
> first backport commit 6ec88fcb4aa2c33fe2fe2a23c576a7e2581c5c3d changes
> l2cap_move_channel_confirm_rsp and not the l2cap_information_rsp. So
> revert this and fix at the correct position.
> 
> commit 3f6fa3d489e127ca5a5b298eabac3ff5dbe0e112 upstream.
> 
> The length check is invalid since the length varies with type of
> info response.
> 
> This was introduced by the commit cb3b3152b2f5939d67005cff841a1ca748b19888
> 
> Because of this, l2cap info rsp is not handled and command reject is sent.
> 
>> ACL data: handle 11 flags 0x02 dlen 16
>         L2CAP(s): Info rsp: type 2 result 0
>           Extended feature mask 0x00b8
>             Enhanced Retransmission mode
>             Streaming mode
>             FCS Option
>             Fixed Channels
> < ACL data: handle 11 flags 0x00 dlen 10
>         L2CAP(s): Command rej: reason 0
>           Command not understood
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Jaganath Kanakkassery <jaganath.k@samsung.com>
> Signed-off-by: Chan-Yeol Park <chanyeol.park@samsung.com>
> Signed-off-by: Gustavo Padovan <gustavo.padovan@collabora.co.uk>
> Cc: Jianguo Wu <wujianguo@huawei.com>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: Tim Niemeyer <tim.niemeyer@corscience.de>
> Acked-by: Johan Hedberg <johan.hedberg@intel.com>
> ---
> Patch for 3.4-stable.
> 

Queued up for 3.4. Thanks!
