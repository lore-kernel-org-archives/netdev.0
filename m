From: Jiri Pirko <jiri@resnulli.us>
Subject: IFF_NOARP behaviour
Date: Fri, 4 Jan 2013 16:02:57 +0100
Message-ID: <20130104150257.GA1606@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:33101 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741Ab3ADPDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 10:03:03 -0500
Received: by mail-vc0-f172.google.com with SMTP id fw7so16995848vcb.3
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 07:03:02 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

When I set IFF_NOARP on ordinary ethernet device and try for example
ping to some ip withing the configured network, I see that the frames
have the same dst MAC as src MAC (iface MAC). Is this correct?
Is this behaviour documented somewhere?

Thanks a lot.

Jiri
