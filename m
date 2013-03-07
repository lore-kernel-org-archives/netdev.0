From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] VSOCK: Split vm_sockets.h into kernel/uapi
Date: Fri, 8 Mar 2013 07:24:53 +0800
Message-ID: <20130307232453.GD10304@kroah.com>
References: <1362669973-26984-1-git-send-email-acking@vmware.com>
	<26621.1362675490@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: David Howells <dhowells@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <26621.1362675490@warthog.procyon.org.uk>
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

On Thu, Mar 07, 2013 at 04:58:10PM +0000, David Howells wrote:
> Andy King <acking@vmware.com> wrote:
> 
> > Split the vSockets header into kernel and UAPI parts.  The former gets the bits
> > that used to be in __KERNEL__ guards, while the latter gets everything that is
> > user-visible.  Tested by compiling vsock (+transport) and a simple user-mode
> > vSockets application.
> > 
> > Reported-by: David Howells <dhowells@redhat.com>
> > Acked-by: Dmitry Torokhov <dtor@vmware.com>
> > Signed-off-by: Andy King <acking@vmware.com>
> 
> Acked-by: David Howells <dhowells@redhat.com>

David, is there any rush to get stuff like this into 3.9 for any
uapi-type changes, or can it just wait for 3.10?

thanks,

greg k-h
