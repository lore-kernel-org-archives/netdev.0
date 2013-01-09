From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Tue, 8 Jan 2013 18:22:04 -0800
Message-ID: <20130109022204.GA22875@dtor-ws.eng.vmware.com>
References: <20130109002110.GB5296@kroah.com>
	<20130108.173056.1029788106028104571.davem@davemloft.net>
	<1683801.VNKd61ZM1Q@dtor-d630.eng.vmware.com>
	<20130108.174601.1788895671912734725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

On Tue, Jan 08, 2013 at 05:46:01PM -0800, David Miller wrote:
> From: Dmitry Torokhov <dtor@vmware.com>
> Date: Tue, 08 Jan 2013 17:41:44 -0800
> 
> > On Tuesday, January 08, 2013 05:30:56 PM David Miller wrote:
> >> From: Greg KH <gregkh@linuxfoundation.org>
> >> Date: Tue, 8 Jan 2013 16:21:10 -0800
> >> 
> >> > On Tue, Jan 08, 2013 at 03:59:08PM -0800, George Zhang wrote:
> >> >> * * *
> >> >> 
> >> >> This series of VSOCK linux upstreaming patches include latest udpate from
> >> >> VMware to address Greg's and all other's code review comments.
> >> > 
> >> > Dave, you acked these patches a while ago,
> >> 
> >> Really?  I'd like to see where I did that.
> >> 
> >> Instead, what I remember doing was deferring to the feedback these
> >> folks received, stating that ideas that the virtio people had
> >> mentioned should be considered instead.
> >> 
> >> http://marc.info/?l=linux-netdev&m=135301515818462&w=2
> > 
> > I believe Andy replied to Anthony's AF_VMCHANNEL post and the differences
> > between the proposed solutions.
> 
> I'd much rather see a hypervisor neutral solution than a hypervisor
> specific one which this certainly is.

Objectively speaking neither solution is hypervisor neutral as there are
hypervisors that implement either VMCI or virtio or something else
entirely.

Our position is that VSOCK feature set is more complete and that it
should be possible to use transports other than VMCI for VSOCK traffic,
should interested parties implement them, and on this basis we ask to
include VSOCK.

Thanks,
Dmitry
