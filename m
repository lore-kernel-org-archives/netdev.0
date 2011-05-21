From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sat, 21 May 2011 18:43:28 +0800
Message-ID: <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net, jesse@nicira.com, ebiederm@xmission.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55824 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092Ab1EUKnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 06:43:49 -0400
Received: by bwz15 with SMTP id 15so3546086bwz.19
        for <netdev@vger.kernel.org>; Sat, 21 May 2011 03:43:48 -0700 (PDT)
In-Reply-To: <20110521072925.GA2588@jirka.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 21, 2011 at 3:29 PM, Jiri Pirko <jpirko@redhat.com> wrote:
>
> I do not see a reason why to not emulate that. To make paths as much
> similar as they can be, that is the point of this patch.
>
> I think it would be better to fix an issue you are pointing at
> rather that revert this.
>

In my opinion, the hardware accelerated VLAN RX is just a special case
of the non hardware accelerated VLAN RX with header reordering. For
promiscuous NICs and bridges, hw-accel-vlan-rx is just disabled.

I have tried to fix all the issues, but failed in a clean way. Please try.

Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
