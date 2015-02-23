From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 13/16] i40e: Fix i40e_ndo_set_vf_spoofchk
Date: Mon, 23 Feb 2015 19:18:19 +0200
Message-ID: <CAJ3xEMgf1ue3Byt3n1+LYFFKED8fq3RXJhqihTY=X6cww_MQkg@mail.gmail.com>
References: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1424661944-1779-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Greg Rose <gregory.v.rose@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:51759 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbbBWRSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 12:18:20 -0500
Received: by mail-oi0-f46.google.com with SMTP id x69so14662379oia.5
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 09:18:19 -0800 (PST)
In-Reply-To: <1424661944-1779-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2015 at 5:25 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>
> The netdev op that allows the operator to turn MAC/VLAN spoof checking on
> and off did not include the flag for VLAN spoof checking.  This patch
> fixes that problem.

If we're on VST mode, the VF isn't aware their traffic is tagged with
vlan-id Y and if they try to send with vlan-id X I assume you are
forcing it to be Y, right?

If we're on VGT mode, what spoof check you can do? we don't have a
model for allowed vlans, did I miss something?
