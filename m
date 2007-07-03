From: "Ayyappan Veeraiyan" <Ayyappan.Veeraiyan@intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI Express adapters...
Date: Tue, 3 Jul 2007 15:01:24 -0700
Message-ID: <ae4a4a920707031501h52aa2657o691ebba4e108a61d@mail.gmail.com>
References: <20070702214238.GA7085@infradead.org>
	 <E35F4F4D7F6C9E4E826FEC1F86CEF583041934FE@orsmsx412.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, netdev@vger.kernel.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: "Christoph Hellwig" <hch@infradead.org>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:18244 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbXGCWBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 18:01:25 -0400
Received: by py-out-1112.google.com with SMTP id u77so3503911pyb
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2007 15:01:24 -0700 (PDT)
In-Reply-To: <E35F4F4D7F6C9E4E826FEC1F86CEF583041934FE@orsmsx412.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/2/07, Veeraiyan, Ayyappan <ayyappan.veeraiyan@intel.com> wrote:
> On 7/2/07, Christoph Hellwig <hch@infradead.org> wrote:

> The submitted driver code supports single queue version in case of MSIX
> allocation failures... As I said in the other mail, I feel, restricting
> to single Rx queue in NAPI mode is better approach till Stephen's and
> DaveM' work of separating NAPI from netdevice is done..
>
> > Lots of drivers where the interface name is assigned after request_irq
> > just use an internal name, e.g. ixgbeX in the case of this driver.
> >

Actually looking closer, we don't need to worry about interface name
change after request_irq. This driver calls request_irq only on
interface up. If interface is up, kernel (dev.c) doesn't allow the
name change. So it is a non-issue for this driver.

Ayyappan
