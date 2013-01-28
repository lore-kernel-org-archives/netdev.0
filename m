From: Romain Francoise <romain@orebokech.com>
Subject: Re: [PATCH] vhost-net: fall back to vmalloc if high-order allocation fails
Date: Mon, 28 Jan 2013 10:23:32 +0100
Message-ID: <87ham1u0dn.fsf@silenus.orebokech.com>
References: <87k3r31vbc.fsf@silenus.orebokech.com>
	<20130123210411.GA9055@redhat.com>
	<20130127.221137.1761549497221263360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mst@redhat.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130127.221137.1761549497221263360.davem@davemloft.net> (David
	Miller's message of "Sun, 27 Jan 2013 22:11:37 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> I'm not going to apply this vmalloc patch, because if I apply it the
> fundamental problem here just gets swept under the carpet even longer.

No problem, I'll keep this as a local change until vhost-net's allocation
strategy gains some sanity.

Thanks.
