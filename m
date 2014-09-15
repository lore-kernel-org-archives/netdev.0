From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 net-next 3/7] fou: Add GRO support
Date: Mon, 15 Sep 2014 18:00:00 +0300
Message-ID: <CAJ3xEMhwdkNDZxSZGw3dtnfoyPHBiOTw-c5DvQPpFZTf1yhEhQ@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<1410750483-3236-4-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:59950 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbaIOPAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 11:00:07 -0400
Received: by mail-oi0-f44.google.com with SMTP id x69so2631571oia.31
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 08:00:00 -0700 (PDT)
In-Reply-To: <1410750483-3236-4-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 6:07 AM, Tom Herbert <therbert@google.com> wrote:
> Implement fou_gro_receive and fou_gro_complete, and populate these
> in the correponsing udp_offloads for the socket. Added ipproto to
> udp_offloads and pass this from UDP to the fou GRO routine in proto
> field of napi_gro_cb structure.


Do we really need that  extra hop of fou4_gro_receive/complete?
can't we somehow plant the gro receive/complete (say) GRE handlers in
the udp offload
struct with the UDP port that related to (say) GRE over UDP tunneling?

Or.
