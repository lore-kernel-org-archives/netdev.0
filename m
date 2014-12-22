From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] OVS + BPF, make sense?
Date: Mon, 22 Dec 2014 10:53:21 +0100
Message-ID: <20141222095321.GA21348@pox.localdomain>
References: <CACzMAJLtTKM57tD=COrZ5KOrZJVPVcUab=t2+y=CEU1e5xHV8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.com" <dev@openvswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:35527 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754289AbaLVJxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 04:53:25 -0500
Received: by mail-wg0-f53.google.com with SMTP id l18so6250745wgh.12
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 01:53:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CACzMAJLtTKM57tD=COrZ5KOrZJVPVcUab=t2+y=CEU1e5xHV8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot for sharing these minutes.

On 12/19/14 at 06:49pm, Andy Zhou wrote:
> Possible use cases of BPF in OVS Linux kernel datapath
> ===========================================
>
> [...]
>
> 4. Using BPF to implement overall OVS kernel module functionality
> 
>    Alexei likes this approach the most. The potential benefits are:

This would be my favourite as well long term assuming that the
performance benefits we hope for can be proven. A logical evolutionary
process might be 2, 3 and then go for the full coverage.

A small but: We can't just remove the existing Netlink based action
data path as non-OVS users exist which rely on it. So this would need
to exist in parallel unless we can get all users on board to transition
over to this new architecture.
