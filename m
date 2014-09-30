From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 30 Sep 2014 15:11:11 -0700
Message-ID: <1412115071.16704.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	 <CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
	 <CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
	 <CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
	 <CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
	 <CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
	 <CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
	 <20140930143700.3dffac4d@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Andy Zhou <azhou@nicira.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53465 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbaI3WLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 18:11:14 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so7085557pab.19
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 15:11:13 -0700 (PDT)
In-Reply-To: <20140930143700.3dffac4d@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 14:37 -0700, Stephen Hemminger wrote:

> Software GSO at driver level is sometimes better anyway because it means driver can
> enqueue a burst of packets into Tx ring.

Yes, and it can save a lot of churn (allocating sk_buff, copying ~256
bytes, bunch of atomic ops...)
