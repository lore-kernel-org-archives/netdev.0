From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v6] switchdev: fix stp update API to work with
 layered netdevices
Date: Sat, 21 Mar 2015 20:21:08 -0700
Message-ID: <CAE4R7bDt2JM_ZXTrqq9Hz3ZDJbfb1=_06b8LftE-3-BBsONp_Q@mail.gmail.com>
References: <1426958848-2781-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:36075 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbbCVDVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 23:21:09 -0400
Received: by qgez102 with SMTP id z102so33667868qge.3
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 20:21:08 -0700 (PDT)
In-Reply-To: <1426958848-2781-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 21, 2015 at 10:27 AM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> make it same as the netdev_switch_port_bridge_setlink/dellink
> api (ie traverse lowerdevs to get to the switch port).
>
> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
> direct bridge ports can be stacked netdevices (like bonds
> and team of switch ports) which may not implement this ndo.
>
> v2 to v3:
>         - remove changes to bond and team. Bring back the
>         transparently following lowerdevs like i initially
>         had for setlink/getlink
>         (http://www.spinics.net/lists/netdev/msg313436.html)
>         dave and scott feldman also seem to prefer it be that
>         way and move to non-transparent way of doing things
>         if we see a problem down the lane.
>
> v3 to v4:
>         - fix ret initialization
>
> v4 to v5:
>         - return err on first failure (scott feldman)
>
> v5 to v6:
>         - change variable name (err) and initialize to
>         -EOPNOTSUPP (scott feldman).
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
