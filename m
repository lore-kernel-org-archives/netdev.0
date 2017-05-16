From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] [PATCH net-next 3/9] nfp: support LSO2 capability
Date: Tue, 16 May 2017 08:56:07 +0200
Message-ID: <20170516065605.GA11965@vergenet.net>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
 <20170516005523.26124-4-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Edwin Peer <edwin.peer@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34170 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdEPG4J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 02:56:09 -0400
Received: by mail-qk0-f182.google.com with SMTP id k74so119003294qke.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 23:56:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170516005523.26124-4-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 05:55:17PM -0700, Jakub Kicinski wrote:
> From: Edwin Peer <edwin.peer@netronome.com>
> 
> Firmware advertising the LSO2 capability exploits driver provided L3 and L4
> offsets in order to avoid parsing packet headers in the TX path. The vlan
> field in struct nfp_net_tx_desc is repurposed, making TXVLAN a mutually
> exclusive configuration to LSO2.
> 
> Signed-off-by: Edwin Peer <edwin.peer@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
