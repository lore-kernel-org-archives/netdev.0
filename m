From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PERF RESULTS] virtio and vhost-net performance enhancements
Date: Thu, 26 May 2011 21:51:32 +0530
Message-ID: <OFF9D0E604.B865A006-ON6525789C.00597010-6525789C.0059987A@in.ibm.com>
References: <cover.1305846412.git.mst@redhat.com> <OF0EFA7BA9.BB2C2860-ON6525789C.0053EE3A-6525789C.005513CC@in.ibm.com> <OFE30C8D78.526FF88D-ON8725789C.00563B8C-8825789C.0056469F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	Carsten Otte <cotte@de.ibm.com>, habanero@linux.vnet.ibm.com,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	kvm@vger.kernel.org, lguest@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org,
	linux390@de.ibm.com, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	virtualization@lists.linux-foundation.org
To: Shirley Ma <xma@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OFE30C8D78.526FF88D-ON8725789C.00563B8C-8825789C.0056469F@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shirley Ma <xma@us.ibm.com> wrote on 05/26/2011 09:12:22 PM:

> Could you please try TCP_RRs as well?

Right. Here's the result for TCP_RR:

__________________________________
#       RR%     SD%     CPU%
__________________________________
1       4.5       -31.4    -27.9
2       5.1       -9.7      -5.4
4       60.4     -13.4     38.8
8       67.8     -13.5     45.0
16     55.8     -8.0       43.2
32     66.9     -14.1     43.3
64     47.2     -23.7     12.2
96     29.7     -11.8     14.3
128    8.0       2.2       10.7
___________________________________
BW: 37.3%   SD: -6.7%   CPU: 15.7%
___________________________________

Thanks,

- KK

