From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: copy_from_user -> __copy_from_user
Date: Sun, 06 Mar 2011 18:03:39 -0800 (PST)
Message-ID: <20110306.180339.193718218.davem@davemloft.net>
References: <20110306113349.GA24333@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110306113349.GA24333@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 6 Mar 2011 13:33:49 +0200

> copy_from_user is pretty high on perf top profile,
> replacing it with __copy_from_user helps.
> It's also safe because we do access_ok checks during setup.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Is Rusty going to take this or should I?
