From: Krzysztof Kolasa <kkolasa@winsoft.pl>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Tue, 14 Oct 2014 15:25:09 +0200
Message-ID: <543D2435.8090002@winsoft.pl>
References: <543AB655.6060603@winsoft.pl>	<1413139613.9362.78.camel@edumazet-glaptop2.roam.corp.google.com>	<CAHA+R7OWpjO0AbwteOAfxd1fej6BcjXR99xy+MnkZ8y+JZ8f4g@mail.gmail.com> <CAHA+R7NOvmyDo_Up32z1oJKCEmCqywRyTkbio4i4n1J+bNg4Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, edumazet@gmail.com,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps01.winsoft.pl ([5.133.9.51]:35529 "EHLO vps01.winsoft.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755229AbaJNNZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2014 09:25:16 -0400
In-Reply-To: <CAHA+R7NOvmyDo_Up32z1oJKCEmCqywRyTkbio4i4n1J+bNg4Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 14.10.2014 o 02:09, Cong Wang pisze:
> On Mon, Oct 13, 2014 at 4:59 PM, Cong Wang <cwang@twopensource.com> wrote:
>> Probably not related with this bug, but with regarding to the
>> offending commit, what's the point of the memmove() in tcp_v4_rcv()
>> since ip_rcv() already clears IPCB()?
> Oh, ip options are actually saved in ip_rcv_finish()... Hmm, looks scary
> to play with variable-length array with memmove()....
>
On my other old laptop with 32bit kernel next and graphics card Intel 
945GM just after the revert commit working OK,
before, after login to gnome shell in some seconds decorations disappear

32 bit Ubuntu 12.04.5 LTS, gnome shell, kernel source next 14-10-2014

Can anyone confirm this ?
