From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Fri, 15 Feb 2013 11:32:36 +0100
Message-ID: <511E0EC4.9030405@redhat.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Andy King <acking@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1360196636-9357-2-git-send-email-acking@vmware.com>
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

On 02/07/13 01:23, Andy King wrote:
> +/* Use this as the destination CID in an address when referring to the
> + * hypervisor.  VMCI relies on it being 0, but this would be useful for other
> + * transports too.
> + */
> +
> +#define VMADDR_CID_HYPERVISOR 0
> +
> +/* This CID is specific to VMCI and can be considered reserved (even VMCI
> + * doesn't use it anymore, it's a legacy value from an older release).
> + */
> +
> +#define VMADDR_CID_RESERVED 1
> +
> +/* Use this as the destination CID in an address when referring to the host
> + * (any process other than the hypervisor).  VMCI relies on it being 2, but
> + * this would be useful for other transports too.
> + */
> +
> +#define VMADDR_CID_HOST 2

CIDs larger than 2 will address other VMs on the same host, with the
hypervisor forwarding the data from one guest to the other and back?

How does VMADDR_CID_HOST work?  Given the age of the vsock transport
layer I don't think you have a vsock_transport_host.ko module ...

Is there some registry for the port numbers?

cheers,
  Gerd
