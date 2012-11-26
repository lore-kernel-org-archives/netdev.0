From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 086/493] net: remove use of __devexit_p
Date: Mon, 26 Nov 2012 09:35:18 -0800
Message-ID: <20121126173518.GA11127@dtor-ws.eng.vmware.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
	<1353349642-3677-86-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, "Michael S. Tsirkin" <mst@redhat.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, gregkh@linuxfoundation.org,
	virtualization@lists.linux-foundation.org,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1353349642-3677-86-git-send-email-wfp5p@virginia.edu>
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

On Mon, Nov 19, 2012 at 01:20:35PM -0500, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
> needed.
> 
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: Rusty Russell <rusty@rustcorp.com.au> 
> Cc: "Michael S. Tsirkin" <mst@redhat.com> 
> Cc: Shreyas Bhatewara <sbhatewara@vmware.com> 
> Cc: "VMware, Inc." <pv-drivers@vmware.com> 
> Cc: Francois Romieu <romieu@fr.zoreil.com> 
> Cc: virtualization@lists.linux-foundation.org 
> Cc: netdev@vger.kernel.org 
> Cc: xen-devel@lists.xensource.com 
> ---
>  drivers/net/virtio_net.c          | 2 +-
>  drivers/net/vmxnet3/vmxnet3_drv.c | 2 +-

For VMXNET3:
 
Acked-by: Dmitry Torokhov <dtor@vmware.com>

Thanks,
Dmitry
