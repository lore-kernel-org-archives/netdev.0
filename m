From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH V2 0/4] Enable bus master till the FLR completes for
 Chelsio T4
Date: Mon, 12 Aug 2013 15:17:04 -0600
Message-ID: <CAErSpo7=oBG3tJBpwscnL-4D-9kLhHUrQSZFrRRC4sBsT2_U2Q@mail.gmail.com>
References: <1375784319-25760-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Casey Leedom <leedom@chelsio.com>, tomreu@chelsio.com,
	divy@chelsio.com, dm@chelsio.com, nirranjan@chelsio.com,
	eilong@broadcom.com, netdev <netdev@vger.kernel.org>
To: Vipul Pandya <vipul@chelsio.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1375784319-25760-1-git-send-email-vipul@chelsio.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 6, 2013 at 4:18 AM, Vipul Pandya <vipul@chelsio.com> wrote:
> This patch series adds device specific reset method for Chelsio T4 adapters.
>
> The series also adds new routine, pci_wait_for_pending_transaction, to wait for
> pending pci transaction. There are few places where waiting for pending pci
> transaction code was duplicated. This patch series also replaces occurances of
> duplicate code.
>
> This patch series is built against Bjorn Helgaas pci tree next branch. We would
> like to merge this series via the same.
>
> I have Cced respective maintainers of the modified drivers. Kindly review and
> let us know in case of any review comments.
>
> Thanks,
> Vipul Pandya
>
> V2: Added pci_wait_for_pending_transaction routine and replaced it at respective
> places. Made the patch series for the same.
> V2: Used dev->msix_cap directly for capability offset
> V2: Removed use of 'rc' variable.
>
> Casey Leedom (4):
>   pci: Add pci_wait_for_pending_transaction to wait for pending pci
>     transaction
>   pci: Enable bus master till the FLR completes
>   bnx2x: Use pci_wait_for_pending_transaction instead of for loop
>   pci: Use pci_wait_for_pending_transaction instead of for loop
>
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 18 +----
>  drivers/pci/pci.c                                | 38 ++++++----
>  drivers/pci/quirks.c                             | 97 ++++++++++++++++++++----
>  include/linux/pci.h                              |  1 +
>  4 files changed, 109 insertions(+), 45 deletions(-)

Applied to my "next" branch for v3.12, thanks!

Bjorn
