From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Sat, 12 Apr 2008 11:59:50 +0100
Message-ID: <20080412115950.1cbb9cfa@core>
References: <m3prtzsszg.fsf@maximus.localdomain>
	<m3tzj92xq6.fsf@maximus.localdomain>
	<m33aqedg0a.fsf@maximus.localdomain>
	<m37if4oz1g.fsf@maximus.localdomain>
	<20080411221448.22b69ff5.akpm@linux-foundation.org>
	<m3prsva3y7.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761488AbYDLLEy@vger.kernel.org>
In-Reply-To: <m3prsva3y7.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 12 Apr 2008 10:10:40 +0200
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > It never hurts to resend.  It was 6000 patches ago and my mind is a blank.
> 
> Sure, here is it. Some description, well:
> 
> PPP support in generic HDLC in Linux 2.6.25 is broken and will cause
> a kernel panic when a device configured in PPP mode is activated.
> 
> It will be replaced by new PPP implementation after Linux 2.6.25 is
> released.

Thats a pretty bad regression. Surely the correct fix is to revert the
change series that caused the breakage then re-merge that and fixes for
HDLC PPP for 2.6.26, not just leave it broken ?
