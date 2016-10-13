From: Chris Rorvick <chris-FAYdYWbMHyxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] iwlwifi: pcie: fix SPLC structure parsing
Date: Thu, 13 Oct 2016 08:56:38 -0500
Message-ID: <CAEUsAPaqyxA1=3ktisBO3Vrw9ygi7PSrk32Rw+iyHVe_WB1oyg@mail.gmail.com>
References: <1476349269.3880.18.camel@coelho.fi> <20161013102155.14547-1-luca@coelho.fi>
 <1476358075.1999.5.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
        kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, oren.givon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
To: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476358075.1999.5.camel-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Luca,

> On Thu, 2016-10-13 at 13:21 +0300, Luca Coelho wrote:
> Could you please give this a spin? I have tested it with some handmade
> ACPI tables in QEMU and it seems to work fine now.

Tested-by: Chris Rorvick <chris-FAYdYWbMHyxBDgjK7y7TUQ@public.gmane.org>

I think the debug output looks as expected, see below for the first 20
lines or so.  And, more importantly, everything seems to be working!
:-)

Thanks!

Chris

==========

iwlwifi 0000:3a:00.0: L1 Enabled - LTR Disabled
iwlwifi: module verification failed: signature and/or required key
missing - tainting kernel
Intel(R) Wireless WiFi driver for Linux
Copyright(c) 2003- 2015 Intel Corporation
iwlwifi 0000:3a:00.0: U iwl_pcie_prepare_card_hw iwl_trans_prepare_card_hw enter
iwlwifi 0000:3a:00.0: U iwl_pcie_set_hw_ready hardware ready
iwlwifi 0000:3a:00.0: U iwl_request_firmware attempting to load
firmware 'iwlwifi-8000C-24.ucode'
iwlwifi 0000:3a:00.0: Direct firmware load for iwlwifi-8000C-24.ucode
failed with error -2
iwlwifi 0000:3a:00.0: U iwl_request_firmware attempting to load
firmware 'iwlwifi-8000C-23.ucode'
iwlwifi 0000:3a:00.0: Direct firmware load for iwlwifi-8000C-23.ucode
failed with error -2
iwlwifi 0000:3a:00.0: U iwl_request_firmware attempting to load
firmware 'iwlwifi-8000C-22.ucode'
iwlwifi 0000:3a:00.0: Direct firmware load for iwlwifi-8000C-22.ucode
failed with error -2
iwlwifi 0000:3a:00.0: U iwl_request_firmware attempting to load
firmware 'iwlwifi-8000C-21.ucode'
iwlwifi 0000:3a:00.0: U iwl_req_fw_callback Loaded firmware file
'iwlwifi-8000C-21.ucode' (2394060 bytes).
iwlwifi 0000:3a:00.0: U iwl_parse_tlv_firmware unknown TLV: 48
iwlwifi 0000:3a:00.0: U iwl_parse_tlv_firmware GSCAN is supported but
capabilities TLV is unavailable
iwlwifi 0000:3a:00.0: U splc_get_pwr_limit No element for the WiFi
domain returned by the SPLC method.
iwlwifi 0000:3a:00.0: U set_dflt_pwr_limit Default power limit set to 0
iwlwifi 0000:3a:00.0: loaded firmware version 21.302800.0 op_mode iwlmvm
iwlwifi 0000:3a:00.0: Detected Intel(R) Dual Band Wireless AC 8260, REV=0x208
