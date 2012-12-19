From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH V2 00/12] Add basic VLAN support to bridges
Date: Wed, 19 Dec 2012 10:10:06 +0200
Message-ID: <20121219101006.7086faef@pixies.home.jungo.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:39493 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247Ab2LSISB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 03:18:01 -0500
Received: by mail-ea0-f176.google.com with SMTP id d13so669784eaa.35
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 00:18:00 -0800 (PST)
In-Reply-To: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Vlad,

On Tue, 18 Dec 2012 14:00:51 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> A single vlan may also be designated as untagged.  Any untagged traffic
> recieved by the port will be assigned to this vlan.

Why the "untagged vlan" is per-bridge global?
Usually, 802.1q switches define the PVID (port's VID) which controls
the value of VID, in case ingress frame is either untagged or
priority-tagged (per port configuration).
This gives greater flexibility.

> Any traffic exiting
> the port with a VID matching the untagged vlan will exit untagged (the
> bridge will strip the vlan header).  This is similar to "Native Vlan" support
> available in most switches.

802.1q switches usually allow conifguring per-vlan, per-port
tagged/untagged egress policy: each vid has its port membership map and
an accompanying port egress-policy map.
This gives great flexibility defining all sorts of configurations.

Personally, I'd prefer a fully flexible vlan bridge allowing all sorts
of configurations (as available in 802.1q switches).

What's the reason limiting such configurations?

Regards,
Shmulik
