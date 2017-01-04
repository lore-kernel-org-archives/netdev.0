From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2 net-next] tc: flower: support matching flags
Date: Wed, 4 Jan 2017 11:33:03 +0100
Message-ID: <20170104103301.GA30008@penelope.horms.nl>
References: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
 <20170102195522.7488179b@griffin>
 <1ec4f4ca-08e0-84fc-34c6-b3868d756050@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33713 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752231AbdADKdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 05:33:17 -0500
Received: by mail-wm0-f43.google.com with SMTP id v3so2631935wme.0
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 02:33:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1ec4f4ca-08e0-84fc-34c6-b3868d756050@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 01:54:34PM +0200, Paul Blakey wrote:

...

Hi Paul,

> Matching name was from the idea that we are doing is matching.
> And regarding documentation/flag names I didn't want tc tool to be need of a
> update each time a new flag is introduced,
> But I guess I can add two options like with ip_proto where you can specify
> known flags by name but can also give a value.
> What do you think about that?
> 
> flags <FLAGS> / <HEX'/'HEX>
> FLAGS => frag/no_frag/tcp_syn/no_tcp_syn ['|'<FLAGS>]*
> e.g: flags frag|no_tcp_syn or flags 0x01/0x15
> and the mask will have a on bits corresponds only to those flags specified.

I suppose a flag is a flag and bitwise masking allows arbitrary matching
on one or more flags. But I wonder if, as per your example above,
it makes sense to mix IP (frag) and TCP flags in the same field of the
classifier.
