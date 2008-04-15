From: "H. Willstrand" <h.willstrand@gmail.com>
Subject: Re: Bad network performance over 2Gbps
Date: Tue, 15 Apr 2008 22:15:14 +0200
Message-ID: <175f5a0f0804151315x1e192fc7p7dac1e84fd154211@mail.gmail.com>
References: <1208282804.23631.27.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Anton Titov" <a.titov@host.bg>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.177]:5818 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298AbYDOUPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 16:15:17 -0400
Received: by el-out-1112.google.com with SMTP id n30so316559elf.21
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 13:15:16 -0700 (PDT)
In-Reply-To: <1208282804.23631.27.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Changed mail list]

On Tue, Apr 15, 2008 at 8:06 PM, Anton Titov <a.titov@host.bg> wrote:
> I use Linux for serving a huge amount of static web on few servers. When
>  network traffic goes above 2Gbit/sec ksoftirqd/5 (not every time 5, but
>  every time just one) starts using exactly 100% CPU time and packet
>  packet loss starts preventing traffic from going up. When the network
>  traffic is lower than 1.9Gbit ksoftirqds use 0% CPU according to top.
>
>  Uplink is 6 gigabit Intel cards bonded together using 802.3ad algorithm
>  with xmit_hash_policy set to layer3+4. On the other side is Cisco 2960
>  switch. Machine is with two quad core Intel Xeons @2.33GHz.
>
>  Here goes a screen snapshot of "top" command. The described behavior
>  have nothing to do with 13% io-wait. It happens even if it is 0%
>  io-wait.
>  http://www.titov.net/misc/top-snap.png
>
>  kernel configuration:
>  http://www.titov.net/misc/config.gz
>
>  /proc/interrupts, lspci, dmesg (nothing intresting there), ifconfig,
>  uname -a:
>  http://www.titov.net/misc/misc.txt.gz
>
>  Is it a Linux bug or some hardware limitation?
>
>  Regards,
>  Anton Titov
>
>  --
>  To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  Please read the FAQ at  http://www.tux.org/lkml/
>
