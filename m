From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] rocker: handle non-bridge master change
Date: Mon, 23 Mar 2015 07:23:09 +0100
Message-ID: <20150323062309.GA2032@nanopsycho.orion>
References: <1427091201-7872-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:32960 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbbCWGXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 02:23:13 -0400
Received: by weop45 with SMTP id p45so129295992weo.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 23:23:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427091201-7872-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 23, 2015 at 07:13:21AM CET, simon.horman@netronome.com wrote:
>Master change notifications may occur other than when joining or
>leaving a bridge, for example when being added to or removed from
>a bond or Open vSwitch.
>
>Previously in those cases rocker_port_bridge_leave() was called
>which results in a null-pointer dereference as rocker_port->bridge_dev
>is NULL because there is no bridge device.
>
>This patch makes provision for doing nothing in such cases.
>
>Fixes: 6c7079450071f ("rocker: implement L2 bridge offloading")
>Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>

Thanks Simon.
