From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] switchdev: fix stp update API to work
 with layered netdevices
Date: Sun, 15 Mar 2015 11:17:55 -0700
Message-ID: <CAE4R7bAscCThvJHmC5y9DPYdSteA3YGNstQ1mdjB1G=k3wHshw@mail.gmail.com>
References: <1426206598-29410-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36779 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbbCOSR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 14:17:56 -0400
Received: by qgg60 with SMTP id 60so23992783qgg.3
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 11:17:55 -0700 (PDT)
In-Reply-To: <1426206598-29410-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 5:29 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> make it same as the netdev_switch_port_bridge_setlink/dellink
> api (ie traverse lowerdevs to get to the switch port).
>
> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because bridge ports
> can be bonds and teams which might not implement this ndo.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

NACK on this.  This is a simpler implementation that doesn't touch
team/bonding/vlan drivers and keeps traversal thru stacked devices in
one place; see my other reply to 0/3 cover letter.
