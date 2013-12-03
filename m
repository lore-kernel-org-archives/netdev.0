From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 21:50:22 +0200
Message-ID: <CAJZOPZKMaS0ewOH2CCbvKCmM9Mjo5NxPQcucODj_q4jkQbUuuQ@mail.gmail.com>
References: <529DF340.70602@mellanox.com>
	<1386090753.30495.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:37433 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755Ab3LCTuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 14:50:22 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so20939632pdi.10
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 11:50:22 -0800 (PST)
In-Reply-To: <1386090753.30495.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 7:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

>> brctl addbr br-vx
>> ip link set br-vx up
>> ifconfig br-vx 192.168.52.144/24 up
>> brctl addif br-vx vxlan42
>> ip link add type veth
>> brctl addif br-vx veth1

> Aside question : If I do not have brctl on my host,
> how can I use "ip" command to perform this "brctl addif" action ?

you can get the sources from
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git
or from http://sourceforge.net/projects/bridge/files/bridge/bridge-utils-1.5.tar.gz/download,
should be trivial to configure and build, if I remember correct


>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
