From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 2/3] mpls: move mpls_hdr to a common
 location
Date: Fri, 30 Sep 2016 19:51:59 +0200
Message-ID: <20160930195159.5b7eed00@griffin>
References: <cover.1475255100.git.jbenc@redhat.com>
        <4556158d9b279156a5c41054f1e803c004bc28e9.1475255100.git.jbenc@redhat.com>
        <CAOrHB_BJqka5HGpeJ1GF42X2kQOmzrLY_LQt4Td6zrAX84Fjow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57248 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932430AbcI3Rwb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 13:52:31 -0400
In-Reply-To: <CAOrHB_BJqka5HGpeJ1GF42X2kQOmzrLY_LQt4Td6zrAX84Fjow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Sep 2016 10:43:42 -0700, pravin shelar wrote:
> There is already struct mpls_label defined in uapi mpls header file.
> Is there reason for not using it here?

I think this should be unified as well. But it's for a different patch
not related to this patchset. This patch just moves the existing
mpls_hdr and mpls_shim_hdr definition to a new place.

In general, I think the mpls code deserves a round of overall cleanups.
It should not block this patchset, though. It can be considered as a
step towards that goal.

 Jiri
