From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH] myri10ge: pci msi and express state save/restore
Date: Mon, 11 Dec 2006 15:41:46 +0100
Message-ID: <457D6E2A.4060405@myri.com>
References: <20061208085231.7aec5ce3@dxpl.pdx.osdl.net> <457D6B35.8000801@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:47184 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S935553AbWLKOmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:42:43 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <457D6B35.8000801@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Stephen Hemminger wrote:
>> The PCI MSI and express state are already saved and restored by the
>> current versions of pci_save_state/pci_restore_state.
>> Therefore it should no longer be necessary for the driver to do it.
>> This patch has not been tested on the hardware.
>>
>> On suspend, handle pci_set_power_state errors, and on resume
>> handle failures in pci_resume_state().
>>
>> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>
> Since Brice is an active maintainer, I would prefer to receive this
> patch via Brice.  I have a pile of patches from him, and don't want to
> invalidate that pile for this patch, even though this patch looks
> fairly sane to me.
>
>     Jeff


OK, I will add the minor changes that I reported to Stephen on Friday,
test the whole thing and resend it.

Thanks,
Brice

