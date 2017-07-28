From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC] switchdev: generate phys_port_name in the core
Date: Fri, 28 Jul 2017 00:27:43 -0700
Message-ID: <20170728002743.48042821@cakuba.netronome.com>
References: <CAJ3xEMhUs0DfMioSU=gqR_hEs=ZFjUM1bA3nA9LwtTgH93ygDQ@mail.gmail.com>
        <20170728023122.1674-1-jakub.kicinski@netronome.com>
        <20170728053507.GA1857@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        David Miller <davem@davemloft.net>, simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34809 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdG1H1r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 03:27:47 -0400
Received: by mail-pf0-f177.google.com with SMTP id q85so92794542pfq.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 00:27:47 -0700 (PDT)
In-Reply-To: <20170728053507.GA1857@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Jul 2017 07:35:07 +0200, Jiri Pirko wrote:
> >+enum {
> >+	NETDEV_PORT_EXTERNAL,
> >+	NETDEV_PORT_EXTERNAL_SPLIT,
> >+	NETDEV_PORT_PCI_PF,  
> 
> Isn't PF also EXTERNAL? Cant VF be split? What I'm getting at, shoudn't
> these be flags?

By external PF do you mean not connected to the current host?  Yes we
could make a flag like that.  Right now I have picked "external" to
avoid too specific names like MAC/PHY/Ethernet...  There could be a
MAC-to-MAC connection for instance, so no PHY involved.  Should we go
with NETDEV_PORT_ETH?

I will make SPLIT into a flag.
