From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Multicast and receive filtering in TUN/TAP
Date: Fri, 11 Jul 2008 17:01:38 +1000
Message-ID: <200807111701.39070.rusty@rustcorp.com.au>
References: <4875428F.4080704@qualcomm.com>
	<200807102223.40717.borntraeger@de.ibm.com>
	<4876C357.3030708@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
        Brian Braunstein <linuxkernel@bristyle.com>,
        Shaun Jackman <sjackman@gmail.com>, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4876C357.3030708@qualcomm.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Friday 11 July 2008 12:20:07 Max Krasnyansky wrote:
> >> I haven't looked at the virtio stuff much, I was assuming that the host
> >> side of it is still the TUN driver. Is it not ?
> >
> > Yes, the host side is still tun/tap. The problem is that qemu doesnt know
> > which multicast addresses are used inside the guest.
>
> Ah, now I see what you meant by virtio_net does not do multicast. I guess
> it should trivial to add. Rusty will clarify it I guess.

Yes, it could certainly be added; that's what feature bits are for :)

Cheers,
Rusty.
