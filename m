From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Mon, 5 Nov 2012 10:19:52 -0800 (PST)
Message-ID: <783561822.12637564.1352139592543.JavaMail.root@vmware.com>
References: <20121105.130917.2098838777626057548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, georgezhang@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121105.130917.2098838777626057548.davem@davemloft.net>
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

> The big and only question is whether anyone can actually use any of
> this stuff without your proprietary bits?

Do you mean the VMCI calls?  The VMCI driver is in the process of being
upstreamed into the drivers/misc tree.  Greg (cc'd on these patches) is
actively reviewing that code and we are addressing feedback.

Also, there was some interest from RedHat into using vSockets as a unified
interface, routed over a hypervisor-specific transport (virtio or
otherwise, although for now VMCI is the only one implemented).

Thanks!
- Andy
