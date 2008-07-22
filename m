From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH 2/4] PCI PM: Make more PCI PM core functionality available to drivers
Date: Tue, 22 Jul 2008 14:26:42 -0700
Message-ID: <200807221426.42725.jbarnes@virtuousgeek.org>
References: <200807191436.40726.rjw@sisk.pl> <200807191439.25371.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Randy Dunlap <rdunlap@xenotime.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755940AbYGVV1S@vger.kernel.org>
In-Reply-To: <200807191439.25371.rjw@sisk.pl>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, July 19, 2008 5:39 am Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
>
> Make more PCI PM core functionality available to drivers
>
> * Export pci_pme_capable() so that it can be called directly by
>   drivers (for example, tg3 needs that).
>
> * Move the state choosing part of pci_prepare_to_sleep() to a
>   separate function, pci_target_state(), that can be called directly
>   by drivers (for example, tg3 needs that).
>
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied to for-linus.  I had to fix things up in light of the kdoc fixes Randy 
sent, but I think I got them right.

Thanks,
Jesse
