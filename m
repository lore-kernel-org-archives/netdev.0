From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 2/2] tun: remove useless codes in tun_chr_aio_read() and
 tun_recvmsg()
Date: Tue, 10 Dec 2013 12:18:09 -0500
Message-ID: <52A74CD1.808@gmail.com>
References: <1386363300-19040-1-git-send-email-zwu.kernel@gmail.com>	<1386363300-19040-2-git-send-email-zwu.kernel@gmail.com> <20131209.203646.425478975392590777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wuzhy@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>, zwu.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131209.203646.425478975392590777.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/09/2013 08:36 PM, David Miller wrote:
> From: Zhi Yong Wu <zwu.kernel@gmail.com>
> Date: Sat,  7 Dec 2013 04:55:00 +0800
> 
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> By checking related codes, it is impossible that ret > len or total_len,
>> so we should remove some useless codes in both above functions.
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> Applied.

Wait a sec.  We want to be able to return a value bigger then len
to trigger a MSG_TRUNC.  Jason has patches for to fix this.  If you
apply this, we'll have to re-introduce this code back in.

Same goes for patch 1/2.

-vlad

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
