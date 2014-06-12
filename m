From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 07/15] i40e: Separate out DCB capability and enabled flags
Date: Thu, 12 Jun 2014 11:22:05 +0300
Message-ID: <CAJZOPZLQ+OUgkHpaSr_aEYLLvyeEHMVwXaruUnj5JZxZ1Wm5RQ@mail.gmail.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1402504404-8954-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Neerav Parikh <neerav.parikh@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:57073 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbaFLIWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 04:22:07 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so1356676qcv.5
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 01:22:05 -0700 (PDT)
In-Reply-To: <1402504404-8954-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2014 at 7:33 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Neerav Parikh <neerav.parikh@intel.com>
>
> Currently if the firmware reports DCB capability the driver enables
> I40E_FLAG_DCB_ENABLED flag. When this flag is enabled the driver
> inserts a tag when transmitting a packet from the port

what is this tag (vlan?) and how it's determined?

> even if there are no DCB traffic classes configured at the port.
