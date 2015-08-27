From: David Miller <davem@davemloft.net>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Thu, 27 Aug 2015 09:40:11 -0700 (PDT)
Message-ID: <20150827.094011.2245604840519777428.davem@davemloft.net>
References: <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com>
	<1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAGr1u3vDQDj6rJYcx2vCsf9KkWf-X=qSh3QD-jAZf7hpUYaAyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, cebbert.lkml@gmail.com,
	Shaun.Crampton@metaswitch.com, linux-kernel@vger.kernel.org,
	Peter.White@metaswitch.com, netdev@vger.kernel.org
To: michael.marineau@coreos.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGr1u3vDQDj6rJYcx2vCsf9KkWf-X=qSh3QD-jAZf7hpUYaAyg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Marineau <michael.marineau@coreos.com>
Date: Thu, 27 Aug 2015 09:16:06 -0700

> On Thu, Aug 27, 2015 at 6:00 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Make sure you backported commit
>> 10e2eb878f3ca07ac2f05fa5ca5e6c4c9174a27a
>> ("udp: fix dst races with multicast early demux")
> 
> Oh, interesting. Looks like that patch didn't get CC'd to stable
> though, is there a reason for that or just oversight?

All networking bug fixes are submitted to -stable by hand by me at a
time of my choosing.  We do not use the "CC: stable" facility, as I
feel it pushes patches into -stable way too quickly and before the
change gets sufficient exposure for regressions in Linus's tree.

The patch in question got submitted last night.
