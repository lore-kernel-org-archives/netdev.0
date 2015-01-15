From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 16/17] i40e: Support for NPAR iSCSI partition with DCB
Date: Thu, 15 Jan 2015 19:11:05 +0200
Message-ID: <CAJ3xEMhXpwBS1PJhrFkojE4OmrcwT1Luuun3pREn+pGb5r60bw@mail.gmail.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1421324368-6860-17-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Neerav Parikh <neerav.parikh@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:34839 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346AbbAORLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 12:11:06 -0500
Received: by mail-oi0-f53.google.com with SMTP id g201so13350303oib.12
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 09:11:06 -0800 (PST)
In-Reply-To: <1421324368-6860-17-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2015 at 2:19 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:

> --- a/drivers/net/ethernet/intel/i40e/i40e_type.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
> @@ -211,6 +211,7 @@ struct i40e_hw_capabilities {
>         bool evb_802_1_qbh; /* Bridge Port Extension */
>         bool dcb;
>         bool fcoe;
> +       bool iscsi; /* Indicates iSCSI enabled */
>         bool mfp_mode_1;
>         bool mgmt_cem;
>         bool ieee_1588;


Hey Jeff, just a 0.02$ small tip... you can easily save the annoying
addition of bool X_is_supported/enabled cap variable for every new cap
with having a 64 bit flags field with a bit per feature... it also
makes the code much more readable.
