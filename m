From: Sathya Perla <sathya.perla@broadcom.com>
Subject: Re: [PATCH net] be2net: don't {en,dis}able filters on BE3 when
 transparent tagging is enabled
Date: Mon, 29 Feb 2016 09:41:08 +0530
Message-ID: <CAKvpyk1BeNUXk5t1tb7OHMwxFWobFv6rrdoXdXrxTAwxOWMi5g@mail.gmail.com>
References: <1456476401-23398-1-git-send-email-ivecera@redhat.com>
	<CAKvpyk3i6U46-9_63CsbpmaJqOYSWcrHjFSo-BZELLriWqkRMQ@mail.gmail.com>
	<56D04408.8070306@redhat.com>
	<CAKvpyk2jT90-hQbgHbm5L-_7FG9bo3uCHkAuG2pQPWBKUJSujw@mail.gmail.com>
	<56D04F94.4060509@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:35938 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850AbcB2ELJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 23:11:09 -0500
Received: by mail-yw0-f179.google.com with SMTP id e63so111907489ywc.3
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2016 20:11:09 -0800 (PST)
In-Reply-To: <56D04F94.4060509@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 6:43 PM, Ivan Vecera <ivecera@redhat.com> wrote:
> Should the MULTICAST bit be masked in any be_cmd_rx_filter() call on BE3's
> VFs if the trans. tagging is enabled?

Not on any be_cmd_rx_filter() call, but on the first call in
be_open()->be_if_enable_filters() where the basic filtering flags are
being enabled and the driver is explicitly checking for the return
status. We have a fix for this already in our internal builds that
hasn't been upstreamed yet. Will send out a patch for this asap.
Thanks for the help on this Ivan!
