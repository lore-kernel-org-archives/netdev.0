From: Jiri Benc <jbenc@redhat.com>
Subject: Re: fib_frontend: Add network specific broadcasts, when it takes a
 sense
Date: Mon, 12 Dec 2016 15:30:35 +0100
Message-ID: <20161212153035.4a751ccc@griffin>
References: <CAD2oYtOS3YKFhhAfXSdJUjKyAx9JpfGz-JLNvGC_mYP7zRp+Rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Denham <tom@tigera.io>,
        Aaron Levy <aaron.levy@coreos.com>,
        Brad Ison <bison@coreos.com>
To: Brandon Philips <brandon.philips@coreos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33168 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752810AbcLLOao (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 09:30:44 -0500
In-Reply-To: <CAD2oYtOS3YKFhhAfXSdJUjKyAx9JpfGz-JLNvGC_mYP7zRp+Rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Dec 2016 15:41:52 -0800, Brandon Philips wrote:
> The issue we have: when creating the VXLAN interface and assigning it
> an address we see a broadcast route being added by the Kernel. For
> example if we have 10.4.0.0/16 a broadcast route to 10.4.0.0 is
> created. This route is unwanted because we assign 10.4.0.0 to one of
> our VXLAN interfaces.

Are you saying you're trying to assign the IP address 10.4.0.0/16 as a
unicast address to an interface? Then you'll run into way more problems
than the one you're describing. You can't have host part of the IP
address consisting of all zeros (or all ones). Just don't do it. Choose
a valid IP address instead.

 Jiri
