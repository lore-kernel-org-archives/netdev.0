From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] virtio-net: remove useless disable on freeze
Date: Thu, 3 May 2012 14:08:45 +0300
Message-ID: <20120503110845.GA25569@redhat.com>
References: <20120404091954.GA3776@redhat.com>
	<20120503105959.GM13421@amit.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Amit Shah <amit.shah@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20120503105959.GM13421@amit.redhat.com>
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

On Thu, May 03, 2012 at 04:29:59PM +0530, Amit Shah wrote:
> On (Wed) 04 Apr 2012 [12:19:55], Michael S. Tsirkin wrote:
> > disable_cb is just an optimization: it
> > can not guarantee that there are no callbacks.
> 
> Even then, what's the harm in keeping it?  If indeed there's an
> attempt to raise an interrupt after the host has been notified, it
> will be suppressed.

It won't. It's not a guarantee, e.g. with event index on
it does nothing at all.

> Also, disable_cb seems to be used elsewhere in the virtio_net.c file,
> to suit similar purposes.
> 
> 		Amit

Where?
