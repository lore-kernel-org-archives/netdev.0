From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PCI fix for some platforms
Date: Wed, 30 Jun 2004 05:01:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E28175.7090403@pobox.com>
References: <80908CC5B2C9DB47AAF8C77892FCB44315F7C9@lion.vector.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, prism54-private@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andriy Korud <a.korud@vector.com.pl>
In-Reply-To: <80908CC5B2C9DB47AAF8C77892FCB44315F7C9@lion.vector.com.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andriy Korud wrote:
> Hi,
> i've noticed that on some platforms (noticed on PPC/XScale embedded) PCI cacheline size is not initialized properly and therefore card uses slow "PCI read memory" command instead of optimal "PCI read memory line", which cause serious bendwidth limitations in case of 3+ cards on single PCI bus.
> 
> Attached patch that fix this issue - please merge review.


See pci_set_mwi()

	Jeff
