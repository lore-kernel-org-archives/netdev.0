From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: copy_from_user -> __copy_from_user
Date: Mon, 7 Mar 2011 08:30:15 +0200
Message-ID: <20110307063014.GA11330@redhat.com>
References: <20110306113349.GA24333@redhat.com>
 <20110306.180339.193718218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110306.180339.193718218.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 06, 2011 at 06:03:39PM -0800, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Sun, 6 Mar 2011 13:33:49 +0200
> 
> > copy_from_user is pretty high on perf top profile,
> > replacing it with __copy_from_user helps.
> > It's also safe because we do access_ok checks during setup.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Is Rusty going to take this or should I?

Sorry about not making this clear.  I'll give it a day or two for review
then put it on the vhost tree myself.
Thanks!
