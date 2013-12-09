From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/2] macvtap: remove useless codes in macvtap_aio_read()
 and macvtap_recvmsg()
Date: Mon, 09 Dec 2013 11:30:54 +0800
Message-ID: <52A5396E.8050806@redhat.com>
References: <1386363300-19040-1-git-send-email-zwu.kernel@gmail.com> <52A28A33.4080306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Zhi Yong Wu <zwu.kernel@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43796 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760379Ab3LIDbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 22:31:21 -0500
In-Reply-To: <52A28A33.4080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2013 10:38 AM, Vlad Yasevich wrote:
> On 12/06/2013 03:54 PM, Zhi Yong Wu wrote:
>> > From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> > 
>> > By checking related codes, it is impossible that ret > len or total_len,
>> > so we should remove some useless coeds in both above functions.
> Looks like commit 6680ec68eff47d36f67b4351bc9836fd6cba9532
> Author: Jason Wang <jasowang@redhat.com>
> Date:   Thu Jul 25 13:00:33 2013 +0800
>
>     tuntap: hardware vlan tx support
>
> Introduced a change in tun_put_user() where we can
> never return a length longer then len or total_len.
> This has an effect that is now impossible to signal
> truncated status.  It seems like a potential loss
> of functionality and it might make sense to restore it.
>
> -vlad

True, will send a patch. For macvtap, we'd better also correct current
behaviour to be same with tun.

Thanks
