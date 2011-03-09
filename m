From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 09 Mar 2011 10:16:00 -0800
Message-ID: <1299694560.25664.125.camel@localhost.localdomain>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
	 <20110309071558.GA25757@redhat.com>
	 <201103091009.27932.tahm@linux.vnet.ibm.com>
	 <1299689493.25664.120.camel@localhost.localdomain>
	 <20110309171603.GD7165@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110309171603.GD7165@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-03-09 at 19:16 +0200, Michael S. Tsirkin wrote:
> On Wed, Mar 09, 2011 at 08:51:33AM -0800, Shirley Ma wrote:
> > On Wed, 2011-03-09 at 10:09 -0600, Tom Lendacky wrote:
> > > > > Vhost is receiving a lot of notifications for packets that are
> to
> > > be
> > > > > transmitted (over 60% of the packets generate a kick_notify). 
> > 
> > This is guest TX send notification when vhost enables notification.
> > 
> > In TCP_STREAM test, vhost exits from reaching NAPI WEIGHT,
> 
> 
> You mean virtio?

Sorry, I messed up NAPI WEIGHT and VHOST NET WEIGHT.

I meant VHOST_NET_WEIGH, vhost exit handdle_tx() from VHOST NET WEIGHT
w/o enabling notification.

> 
> > it rarely
> > enables the notification, vhost re-enters handle_tx from NAPI poll,
> 
> Does NAPI really call handle_tx? Not rx? 

I meant for TX/RX, vhost re-enter handle_tx from vhost_poll_queue() not
from kick_notify.

Shirley

