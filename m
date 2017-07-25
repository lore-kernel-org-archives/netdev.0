From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 10/10] bnxt_en: add support for port_attr_get
 and and get_phys_port_name
Date: Tue, 25 Jul 2017 15:27:54 -0700
Message-ID: <20170725152754.1cab06a6@cakuba.netronome.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
        <1500914069-15724-11-git-send-email-michael.chan@broadcom.com>
        <20170724214521.75bf5857@cakuba.netronome.com>
        <CAKvpyk3=R-ER74wfwNE3yM19EgU+h2TUdp8epRUKEQ69=kco1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:28898 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750857AbdGYW2B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 18:28:01 -0400
In-Reply-To: <CAKvpyk3=R-ER74wfwNE3yM19EgU+h2TUdp8epRUKEQ69=kco1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Jul 2017 15:25:19 +0530, Sathya Perla wrote:
> >> Suggested naming convention is "swXpYsZ", where X is the switch name or ID, Y
> >> is the port name or ID, and Z is the sub-port name or ID.  For example, sw1p1s0
> >> would be sub-port 0 on port 1 on switch 1.  
> >
> > So for physical ports the convention is p<port_id>, and in case of
> > breakout p<port_id>s<subport_id>.  
> 
> I'm sending a follow-up patch that fixes the naming for both the
> external port and the VF-reps as proposed in your RFC ( switchdev:
> clarify ndo_get_phys_port_name() formats)

Thanks!
