From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH] virtio: Avoid virtio_net TX queue over run
Date: Thu, 17 Mar 2011 11:52:16 -0700
Message-ID: <1300387936.3255.57.camel@localhost.localdomain>
References: <1300320595.3255.29.camel@localhost.localdomain>
	 <20110317050538.GD32049@redhat.com>
	 <1300380626.3255.53.camel@localhost.localdomain>
	 <1300381096.6315.315.camel@edumazet-laptop>
	 <1300381265.3255.54.camel@localhost.localdomain>
	 <1300387758.3255.56.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1300387758.3255.56.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-17 at 11:49 -0700, Shirley Ma wrote:
> With a single CPU, before/after with this patch the performance has no
> difference for both UDP and TCP, and it seems hitting TX overrun, CPU
> is
> 100% used. 

Sorry, should be: it seems never hitting TX overrun.

Shirley

