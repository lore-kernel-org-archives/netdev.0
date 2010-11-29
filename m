From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/5 V2] Firewire networking assorted fixes
Date: Mon, 29 Nov 2010 16:02:31 +0100
Message-ID: <20101129160231.2d5000a4@stein>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel <linux1394-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:55602 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117Ab0K2PCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 10:02:44 -0500
In-Reply-To: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Nov 29 Maxim Levitsky wrote:
> This is updated version of the patches.
> I updated the changelogs, addressed comments on patch #2

I haven't applied and tested these patches yet but they look good to me.

Regarding 3/5 (and 4/5 which depends on it), I need of course an ack
from an IPv4 maintainer, or a comment on how to do it differently if
desired.

Patch 5/5 looks good for the next one or two kernel releases. If
progress with firewire-net/-ohci stabilization keeps going like it does
at the moment, we can later remove this logging entirely.  (There is
still the cancel_packet issue to tackle in fw-ohci/-core.)
-- 
Stefan Richter
-=====-==-=- =-== ===-=
http://arcgraph.de/sr/
