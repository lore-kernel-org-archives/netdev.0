From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/6] VSOCK: vsock protocol implementation.
Date: Tue, 6 Nov 2012 10:10:13 +0100
Message-ID: <20121106101013.09806f81@s6510.linuxnetplumber.net>
References: <20121105175730.21472.99155.stgit@promb-2n-dhcp175.eng.vmware.com>
	<20121105180043.21472.95003.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, vm-crosstalk@vmware.com, davem@davemloft.net
To: George Zhang <georgezhang@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121105180043.21472.95003.stgit@promb-2n-dhcp175.eng.vmware.com>
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

On Mon, 05 Nov 2012 10:00:51 -0800
George Zhang <georgezhang@vmware.com> wrote:

> +	/* Added in 2.6.10. */
> +	.owner = THIS_MODULE,

Thanks for submitting this, it will make life easier for distro's
that now have to go through extra effort to include out of mainline
support for Vmware.

You did some scrubbing of the macro's to support multiple kernel
versions, but there are still some leftovers.
This code seems to have a lot of "this added in version xxx"
type comments. These are probably not a good idea to include
in the mainline kernel code. 
