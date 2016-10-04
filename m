From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] openvswitch: correctly fragment packet with
 mpls headers
Date: Tue, 4 Oct 2016 18:59:20 +0200
Message-ID: <20161004185920.229e62de@griffin>
References: <b0cb6efc9bfda8381af880f10fa6b3447f7d3d5d.1475512190.git.jbenc@redhat.com>
        <CAOrHB_Dh=OPUTbbN7QYo9Nz4cV99-k_fT4z7jSOEcnFEDKXQEg@mail.gmail.com>
        <20161004102458.1241605f@griffin>
        <20161004112804.04f25140@griffin>
        <CAOrHB_C55GM=AfYj43VJ-hPRZfwFxm_+8Ls2+7mck2Js1fy9-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50392 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753781AbcJDQ7X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 12:59:23 -0400
In-Reply-To: <CAOrHB_C55GM=AfYj43VJ-hPRZfwFxm_+8Ls2+7mck2Js1fy9-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Oct 2016 09:53:25 -0700, Pravin Shelar wrote:
> This code can be executed on encapsulated geneve or vxlan packets.

How? The encapsulation header is in the form of metadata_dst at this
point and not present in the packet itself. Am I missing something?

If this patch is wrong, then the current push_mpls is wrong, too, it
does the same assumption.

 Jiri
