From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 03 Dec 2013 12:19:21 -0800
Message-ID: <529E3CC9.4060504@intel.com>
References: <529DF340.70602@mellanox.com> <1386090753.30495.33.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZKMaS0ewOH2CCbvKCmM9Mjo5NxPQcucODj_q4jkQbUuuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26140 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754534Ab3LCUTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 15:19:23 -0500
In-Reply-To: <CAJZOPZKMaS0ewOH2CCbvKCmM9Mjo5NxPQcucODj_q4jkQbUuuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/3/2013 11:50 AM, Or Gerlitz wrote:
> On Tue, Dec 3, 2013 at 7:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>>> brctl addbr br-vx
>>> ip link set br-vx up
>>> ifconfig br-vx 192.168.52.144/24 up
>>> brctl addif br-vx vxlan42
>>> ip link add type veth
>>> brctl addif br-vx veth1
>
>> Aside question : If I do not have brctl on my host,
>> how can I use "ip" command to perform this "brctl addif" action ?
>
> you can get the sources from
> git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git
> or from http://sourceforge.net/projects/bridge/files/bridge/bridge-utils-1.5.tar.gz/download,
> should be trivial to configure and build, if I remember correct
>
>


The 'brctl addif' should be the same as setting the master.

#ip link set dev veth1 master br-vs

and then use nomaster to delete the interface.

.John
