From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V5 4/6 net-next] vhost: vhost TX zero-copy support
Date: Mon, 16 May 2011 14:30:49 -0700
Message-ID: <1305581449.3456.54.camel@localhost.localdomain>
References: <1305574484.3456.30.camel@localhost.localdomain>
	 <20110516204540.GD18148@redhat.com>
	 <1305579414.3456.49.camel@localhost.localdomain>
	 <20110516212401.GF18148@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110516212401.GF18148@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-17 at 00:24 +0300, Michael S. Tsirkin wrote:
> Very strange, it sounds like a bug, but I can't tell where: in
> host or in guest. If it's in the guest, we must fix it.
> If in host, we should only fix it if it makes life simpler for us.
> Could you try to nail it down pls?  Another question: will code get
> simpler or more complex if that restriction's removed? 

It should be similar. We still need to maintain the pending list, and
mark the DMA done ids.

I can make a try to narrow this issue down.

Thanks
Shirley
