From: pravin shelar <pshelar@ovn.org>
Subject: Re: [ovs-dev] [PATCH net-next v11 2/6] gre: unset mac header for
 non-TEB packets received by ipgre device
Date: Thu, 7 Jul 2016 13:51:53 -0700
Message-ID: <CAOrHB_DkFO-aTL4=BZGmy5SKvYPyuyBEmJfcrkY72tP25Zc8tg@mail.gmail.com>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com> <1467827996-32547-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:58543 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbcGGUv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 16:51:58 -0400
Received: from mfilter13-d.gandi.net (mfilter13-d.gandi.net [217.70.178.141])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id D0E7841C08A
	for <netdev@vger.kernel.org>; Thu,  7 Jul 2016 22:51:56 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter13-d.gandi.net (mfilter13-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id W1heApx70dRp for <netdev@vger.kernel.org>;
	Thu,  7 Jul 2016 22:51:55 +0200 (CEST)
Received: from mail-it0-f42.google.com (mail-it0-f42.google.com [209.85.214.42])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 4E79A41C096
	for <netdev@vger.kernel.org>; Thu,  7 Jul 2016 22:51:55 +0200 (CEST)
Received: by mail-it0-f42.google.com with SMTP id j185so109282522ith.0
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 13:51:55 -0700 (PDT)
In-Reply-To: <1467827996-32547-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 10:59 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> unset rather than reset mach header for non-TEB packets received by an
> ipgre device.  This allows skb_transport_header_was_set to be subsequently
> used to differentiate TEB and non-TEB packets recieved on an ipgre device.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
