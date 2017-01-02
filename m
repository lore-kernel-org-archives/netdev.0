From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] tools: test case for TPACKET_V3/TX_RING support
Date: Mon, 2 Jan 2017 17:31:55 -0500
Message-ID: <CAF=yD-JLDM9cekGTz7m3VYXmf4d+HEMX4dYZx=sB1X7+5drqsA@mail.gmail.com>
References: <cover.1483309545.git.sowmini.varadhan@oracle.com> <d26567a7226d392b8105f35be5cf25a17dbdf2ed.1483309545.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:35182 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdABWcg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:32:36 -0500
Received: by mail-vk0-f66.google.com with SMTP id x186so30656018vkd.2
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 14:32:36 -0800 (PST)
In-Reply-To: <d26567a7226d392b8105f35be5cf25a17dbdf2ed.1483309545.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 1, 2017 at 5:45 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> Add a test case and sample code for (TPACKET_V3, PACKET_TX_RING)

Thanks for adding this.

walk_v3_tx is almost identical to walk_v1_v2_tx. That function can
just be extended to add a v3 case where it already multiplexes between
v1 and v2.
