From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/1] VM Sockets for Linux upstreaming
Date: Fri, 8 Feb 2013 17:20:44 -0800
Message-ID: <20130209012044.GB5194@dtor-ws.eng.vmware.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1360196636-9357-1-git-send-email-acking@vmware.com>
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

Hi David,

On Wed, Feb 06, 2013 at 04:23:55PM -0800, Andy King wrote:
> In an effort to improve the out-of-the-box experience with Linux kernels for
> VMware users, VMware is working on readying the VM Sockets (VSOCK, formerly
> VMCI Sockets) (vsock) kernel module for inclusion in the Linux kernel. The
> purpose of this post is to acquire feedback on the vsock kernel module.
> 
> Unlike previous submissions, where the new socket family was entirely reliant
> on VMware's VMCI PCI device (and thus VMware's hypervisor), VM Sockets is now
> completely[1] separated out into two parts, each in its own module:
> 
> o Core socket code, which is transport-neutral and invokes transport
>   callbacks to communicate with the hypervisor.  This is vsock.ko.
> o A VMCI transport, which communicates over VMCI with the VMware hypervisor.
>   This is vmw_vsock_vmci_transport.ko, and it registers with the core module
>   as a transport.
> 
> This should provide a path to introducing additional transports, for example
> virtio, with the ultimate goal being to make this new socket family
> hypervisor-neutral.

As Andy mentioned in another e-mail, we would like very much to get
vsock in 3.9 release, so now that it is split into hypervisor neutral
and transport parts is there any high level issues that we need to
resolve before the code can be accepted?

Thanks,
Dmitry
