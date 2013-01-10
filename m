From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Wed, 9 Jan 2013 18:42:57 -0800 (PST)
Message-ID: <1426158581.24554896.1357785777229.JavaMail.root@vmware.com>
References: <50ED25E7.9010609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@vmware.com>, pv-drivers@vmware.com,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <50ED25E7.9010609@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

> > Our position is that VSOCK feature set is more complete and that it
> > should be possible to use transports other than VMCI for VSOCK
> > traffic, should interested parties implement them,
> 
> Implementing other transports requires restructing vsock (and vmci)
> first as the current vsock code is not a hypervisor neutral service.

I'm going to bite the bullet and spend the next couple of days doing
just that: factoring out the VMCI bits and hiding them behind a
transport layer.  It'll be a bit rough, but it'll be a start.  We'll
submit another patch series next week with that.  I'm hoping that'll
get us over this hump, since it should by hypervisor agnostic at
that point.  It'll be up to you guys to add virtio, though :)

And in the meantime, are there any other glaring errors that we need
to address?

Thanks!
- Andy
