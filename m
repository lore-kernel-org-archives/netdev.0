From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [NET] split arp_send into arp_create and arp_xmit
 (resend)
Date: Fri, 6 Feb 2004 16:04:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206160422.018955f3.davem@redhat.com>
References: <200402051559.10075.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmuel Hen <shmulik.hen@intel.com>
In-Reply-To: <200402051559.10075.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 Feb 2004 15:58:56 +0200
Shmuel Hen <shmulik.hen@intel.com> wrote:

> Enable intermediate network drivers like bonding to create an ARP 
> packet and modify it to their needs before sending it, while avoiding 
> code duplication. It does not affect any other place in the kernel 
> that uses arp_send.

Applied, thanks Shmuel.
