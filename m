From: Fan Du <fan.du@windriver.com>
Subject: Re: [Patch net-next] vxlan: do not use vxlan_net before checking
 event type
Date: Fri, 17 Jan 2014 12:28:42 +0800
Message-ID: <52D8B17A.6030301@windriver.com>
References: <1389932410-21080-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:63106 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbaAQE2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 23:28:47 -0500
In-Reply-To: <1389932410-21080-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Cong

On 2014=E5=B9=B401=E6=9C=8817=E6=97=A5 12:20, Cong Wang wrote:
> When cloning a netns, loopback device will be registered
> and therefore an event will be notified. Of course
> vxlan doesn't care about it, therefore should check if it
> is NETDEV_UNREGISTER before getting the vxlan_net struct.
> Otherwise, vxlan_net is probably not initialized yet at
> this point.

I'm bit new to vxlan, but in vxlan_init_module

register_pernet_device is called before register_netdevice_notifier.
By my understanding once register_pernet_device is called,
then subsequent vxlan_notifier_block callback see a valid vxlan_net_id.
I mean execute vxlan_notifier_block callback indicates a valid vxlan_ne=
t_id,
or I miss somewhere else.


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
