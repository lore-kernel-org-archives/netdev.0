From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V3 2/8] Add a new zerocopy device flag
Date: Mon, 2 May 2011 22:53:03 +0300
Message-ID: <20110502195302.GA25619@redhat.com>
References: <1303328216.19336.18.camel@localhost.localdomain>
 <1303328648.19336.24.camel@localhost.localdomain>
 <20110502104257.GA21625@redhat.com>
 <1304362028.20660.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304362028.20660.15.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 02, 2011 at 11:47:08AM -0700, Shirley Ma wrote:
> On Mon, 2011-05-02 at 13:42 +0300, Michael S. Tsirkin wrote:
> > This comment should specify what exactly is the promise the
> > device makes by setting this flag. Specifically, the
> > condition is that no skb fragments are used
> > after the uinfo callback has been called.
> > 
> > The way it's implemented, it probably means the device
> > should not use any of skb_clone, expand head etc.
> 
> Agree. Or maybe force a copy when device uses skb_clone, expand
> head ...?
> 
> Thanks
> Shirley

Copy from userspace upfront without locking is probably cheaper?

-- 
MST
