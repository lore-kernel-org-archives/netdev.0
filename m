From: Andy King <acking@vmware.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Tue, 12 Feb 2013 19:23:02 -0800 (PST)
Message-ID: <89189590.1119233.1360725782323.JavaMail.root@vmware.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
	<511A2043.6040805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <511A2043.6040805@redhat.com>
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

Hi Gerd,

> > +/* Option name for socket's service label.  Use as the option name in
> > + * setsockopt(3) or getsockopt(3) to set or get the service label for a
> > socket.
> > + * The service label is a C-style NUL-terminated string.  Only available
> > for
> > + * hypervisor endpoints.
> > + */
> > +
> > +#define SO_VM_SOCKETS_SERVICE_LABEL 4
> > +
> 
> What is this and how does it work?

Oops, that's specific to ESX.  Thankfully it's only in the header and not
in anything under net/vmw_vsock, so removing it is easy.  I'll send out a
patch in the morning.

Thanks!
- Andy
