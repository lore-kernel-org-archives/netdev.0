From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 3/4] nfp: make use of extended ack message reporting
Date: Tue, 25 Apr 2017 10:20:22 -0400 (EDT)
Message-ID: <20170425.102022.219410555949403896.davem@davemloft.net>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
        <20170425080644.122536-4-jakub.kicinski@netronome.com>
        <9765d004-de19-7cf2-fcfc-1d2e72cded43@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        johannes@sipsolutions.net, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        bblanco@gmail.com, john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946494AbdDYOU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:20:26 -0400
In-Reply-To: <9765d004-de19-7cf2-fcfc-1d2e72cded43@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Tue, 25 Apr 2017 08:42:32 -0400

> So are we going to standardize these strings?

No.

> i.e what if some user has written a bash script that depends on this
> string and it gets changed later.

They can't do that.

It's free form extra information an application may or not provide
to the user when the kernel emits it.
