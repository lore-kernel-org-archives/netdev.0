From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Mon, 4 Feb 2013 20:42:21 -0800 (PST)
Message-ID: <1979127675.2501555.1360039341169.JavaMail.root@vmware.com>
References: <20130108.174601.1788895671912734725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dtor@vmware.com, pv-drivers@vmware.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130108.174601.1788895671912734725.davem@davemloft.net>
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

Hi Dave,

> >> Instead, what I remember doing was deferring to the feedback these
> >> folks received, stating that ideas that the virtio people had
> >> mentioned should be considered instead.
> >> 
> >> http://marc.info/?l=linux-netdev&m=135301515818462&w=2
> > 
> > I believe Andy replied to Anthony's AF_VMCHANNEL post and the
> > differences between the proposed solutions.
> 
> I'd much rather see a hypervisor neutral solution than a hypervisor
> specific one which this certainly is.

We've addressed this with the latest patch series, which I sent earlier
today.  vSockets now has support for pluggable transports, of which VMCI
happens to be the first; all transport code is separated out into its
own module.  So the core is now hypervisor neutral.  Given that, would
you be willing to re-consider it, please?  If at all possible, we'd like
to make the current merge window.

Thanks so much!
- Andy
