From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 0/4] 2.6.5-rc2-mm5 - r8169 queue
Date: Mon, 29 Mar 2004 14:40:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329144034.3d943d12.ak@suse.de>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040329193604.A4744@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Mar 2004 19:36:04 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> There are a few (hopefully) harmless things in the local queue that I'd
> appreciate to go mainline before the second round of r8169 changes.

Do you have any plans to convert it to use DAC?  

I feel a bit uncomfortable with using the IOMMU on x86-64 for gigabit
ethernet because it would be very easy to overflow it at these bandwidths. 
DAC would be much safer.

-Andi
