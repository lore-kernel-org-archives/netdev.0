From: Cong Wang <amwang@redhat.com>
Subject: Re: [Bridge] [Patch] bridge: call NETDEV_ENSLAVE notifiers when adding
 a slave
Date: Fri, 20 May 2011 11:06:28 +0800
Message-ID: <4DD5DAB4.2070709@redhat.com>
References: <1305794393-20775-1-git-send-email-amwang@redhat.com>	<1305800661-4081-1-git-send-email-amwang@redhat.com>	<20110519081213.15c05da2@nehalam> <20110519090411.1f039a88@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@redhat.com>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110519090411.1f039a88@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2011=E5=B9=B405=E6=9C=8820=E6=97=A5 00:04, Stephen Hemminger =
=E5=86=99=E9=81=93:
> On Thu, 19 May 2011 08:12:13 -0700
> Stephen Hemminger<shemminger@linux-foundation.org>  wrote:
>
>> On Thu, 19 May 2011 18:24:17 +0800
>> Amerigo Wang<amwang@redhat.com>  wrote:
>>
>>> In the previous patch I added NETDEV_ENSLAVE, now
>>> we can notify netconsole when adding a device to a bridge too.
>>>
>>> By the way, s/netdev_bonding_change/call_netdevice_notifiers/ in
>>> bond_main.c, since this is not bonding specific.
>>>
>>> Signed-off-by: WANG Cong<amwang@redhat.com>
>>> Cc: Neil Horman<nhorman@redhat.com>
>>>
>>
>> Is there a usage for this? What listens for this notification?
>
> Never mind it was in the first patch which you did not send.
> You should always put a number on group of patches and send
> to all parties.

Ah, sorry, my script simply run get_maintainers.pl to
get the Cc list, so bridge list was not in included in
the first patch.

>
> Also, sending networking patches to LKML is a waste of bandwidth
> please don't bother.

Ok, will fix my script.

Thanks.
