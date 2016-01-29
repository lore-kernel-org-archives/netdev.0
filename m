From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v1] ethtool: properly indent man sub-options
Date: Thu, 28 Jan 2016 23:45:49 -0800
Message-ID: <CAL3LdT6NiSBf1vazisGEj+EwP6HqQY9fMGb6p5AAp1pUPys+_w@mail.gmail.com>
References: <1452217843-18254-1-git-send-email-jesse.brandeburg@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>, bwh@kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32852 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbcA2Hpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 02:45:50 -0500
Received: by mail-io0-f194.google.com with SMTP id f81so5948078iof.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 23:45:50 -0800 (PST)
In-Reply-To: <1452217843-18254-1-git-send-email-jesse.brandeburg@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 7, 2016 at 5:50 PM, Jesse Brandeburg
<jesse.brandeburg@intel.com> wrote:
> The ethtool.8 file was full of lots of incorrectly indented
> bits.  This fixes the arguments to options to be indented in
> a visually appealing way.
>
> Before:
>        -K --features --offload
>               Changes the offload parameters and other features of the
>               specified network device.  The following feature names
>               are built-in and others may be defined by the kernel.
>
>        rx on|off
>               Specifies whether RX checksumming should be enabled.
>
>        tx on|off
>               Specifies whether TX checksumming should be enabled.
>
> After:
>        -K --features --offload
>               Changes  the  offload parameters and other features of the
>               specified network device.  The following feature names are
>               built-in and others may be defined by the kernel.
>
>            rx on|off
>                   Specifies whether RX checksumming should be enabled.
>
>            tx on|off
>                   Specifies whether TX checksumming should be enabled.
>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---
>  ethtool.8.in | 41 +++++++++++++++++++++++++++++++++++++----
>  1 file changed, 37 insertions(+), 4 deletions(-)
>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
