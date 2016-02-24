From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 07/20] igb: add a character device to support AVB
Date: Wed, 24 Feb 2016 22:06:25 +0200
Message-ID: <CAJ3xEMiHz+5n1iHO9s2Vuz_ssgJWTNBU-1gCgf_Bf0Rrc-kA-A@mail.gmail.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1456287984-10459-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gangfeng Huang <gangfeng.huang@ni.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33539 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932396AbcBXUGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 15:06:30 -0500
Received: by mail-io0-f171.google.com with SMTP id z135so63982656iof.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 12:06:25 -0800 (PST)
In-Reply-To: <1456287984-10459-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2016 at 6:26 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Gangfeng Huang <gangfeng.huang@ni.com>

> This patch create a character device for Intel I210 Ethernet controller,

wait, do we want L2 network driver to create char devices

> it can be used for developing Audio/Video Bridging applications,Industrial
> Ethernet applications which require precise timing control over frame
> transmission, or test harnesses for measuring system latencies and sampling
> events.

for various reasons such as the above?

> As the AVB queues (0,1) are mapped to a  user-space application, typical
> LAN traffic must be steered away from these queues. For transmit, this
> driver implements one method registering an ndo_select_queue handler to
> map traffic to queue[3] and set the register MRQC to receive all BE
> traffic to Rx queue[3].
>
> This patch is reference to the Intel Open-AVB project:
> http://github.com/AVnu/Open-AVB/tree/master/kmod/igb
>
> Signed-off-by: Gangfeng Huang <gangfeng.huang@ni.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
