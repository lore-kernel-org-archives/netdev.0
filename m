From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 3/4] i40e: remove pci_assigned_vfs() check while disabling VFs
Date: Tue, 11 Nov 2014 05:52:08 -0800
Message-ID: <CAL3LdT6fwkoGEk5+X+5OFEuRMG+aK9eT-ZT4XZRML9jm_xhrXw@mail.gmail.com>
References: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
	<1415620410-4937-4-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, ariel.elior@qlogic.com,
	linux.nics@intel.com, shahed.shaikh@qlogic.com, ddutile@redhat.com
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:53741 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbaKKNwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 08:52:09 -0500
In-Reply-To: <1415620410-4937-4-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 3:53 AM, Sathya Perla <sathya.perla@emulex.com> wrote:
> From: Vasundhara Volam <vasundhara.volam@emulex.com>
>
> The pci_assigned_vfs() check (while disabling VFs) is being moved to the
> pci-sysfs.c file and will be done before invoking sriov_configure().
>
> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    7 +------
>  1 files changed, 1 insertions(+), 6 deletions(-)

Thanks I will add your patch to my queue.
