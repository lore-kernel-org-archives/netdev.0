From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Thu, 8 Nov 2012 07:47:25 -0800 (PST)
Message-ID: <800083268.16640150.1352389645222.JavaMail.root@vmware.com>
References: <509A06AB.2020700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, David Miller <davem@davemloft.net>,
	georgezhang@vmware.com
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <509A06AB.2020700@redhat.com>
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

>> Also, there was some interest from RedHat into using vSockets as
>> a unified interface, routed over a hypervisor-specific transport
>> (virtio or otherwise, although for now VMCI is the only one
>> implemented).
> 
> Can you outline how this can be done?  From a quick look over the
> code it seems like vsock has a hard dependency on vmci, is that
> correct?

That's correct, VMCI is wired into vSockets and we don't currently
provide any way to insert another transport.

> When making vsock a generic, reusable kernel service it should be
> the other way around:  vsock should provide the core implementation
> and an interface where hypervisor-specific transports (vmci,
> virtio, xenbus, ...) can register themself.

Sorry, that was a bad explanation on my part.  You're absolutely
correct as to how it _should_ work.  But it's up to Red Hat or others
to get the ball rolling and motivate the necessary work on vSockets
to make this happen.  As Greg says, "everyone is lazy and just wants
their code accepted" ;)

Thanks!
- Andy
