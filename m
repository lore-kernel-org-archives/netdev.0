From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] openvswitch: correctly fragment packet with
 mpls headers
Date: Tue, 4 Oct 2016 10:24:58 +0200
Message-ID: <20161004102458.1241605f@griffin>
References: <b0cb6efc9bfda8381af880f10fa6b3447f7d3d5d.1475512190.git.jbenc@redhat.com>
        <CAOrHB_Dh=OPUTbbN7QYo9Nz4cV99-k_fT4z7jSOEcnFEDKXQEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752197AbcJDIZC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 04:25:02 -0400
In-Reply-To: <CAOrHB_Dh=OPUTbbN7QYo9Nz4cV99-k_fT4z7jSOEcnFEDKXQEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Oct 2016 11:04:46 -0700, Pravin Shelar wrote:
> This is not correct way to detect MPLS packet. inner_protocol can be
> set by any tunnel device for using tunnel offloads. So this would
> break the fragmentation for encapsulated packets.

You're right, stupid me.

> How about using eth_p_mpls() as done in do-output()?

Will look into it.

 Jiri
