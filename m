From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 11:51:06 +0200
Message-ID: <20170821115106.70fa1e1d@griffin>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
        <20170818152601.3760aaec@griffin>
        <20170821061109.GA72656@cran64.bj.intel.com>
        <20170821101925.3f9b36a1@griffin>
        <20170821083900.GA74649@cran64.bj.intel.com>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3@ESESSMB107.ericsson.se>
        <20170821113514.6f0ec15e@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A55C@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Yang, Yi" <yi.y.yang@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "blp@ovn.org" <blp@ovn.org>, "e@erig.me" <e@erig.me>
To: Jan Scheurich <jan.scheurich@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45368 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752253AbdHUJvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 05:51:09 -0400
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A55C@ESESSMB107.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 09:42:27 +0000, Jan Scheurich wrote:
> I understand your concern. But not declaring md2 as array is wrong as
> well, as there might not be an MD2 TLV context header. An MD2 NSH
> header is perfectly valid without any TLV. So in any case the user of
> the struct needs to be aware of the NSH semantics.

Good point.

> NSH can be carried over Ethernet with a 14 byte header. In that case
> the total NSH header would typically be 16-bit aligned, so that all
> 32-bit members would be misaligned.

See NET_IP_ALIGN in include/linux/skbuff.h.

 Jiri
