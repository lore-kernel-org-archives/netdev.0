From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/9] liquidio CN23XX VF support
Date: Mon, 31 Oct 2016 08:53:56 -0400 (EDT)
Message-ID: <20161031.085356.305731038030662065.davem@davemloft.net>
References: <1477443430-27170-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <20161029.143126.1818409172503412109.davem@davemloft.net>
        <DM3PR07MB21386FE887D71590E16ED59B81AE0@DM3PR07MB2138.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Raghu.Vatsavayi@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45348 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942308AbcJaMyC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 08:54:02 -0400
In-Reply-To: <DM3PR07MB21386FE887D71590E16ED59B81AE0@DM3PR07MB2138.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
Date: Mon, 31 Oct 2016 07:21:27 +0000

> So please confirm if you want us to remove these two parameters
> num_queues_per_{p,v}f. Then I can remove these module parameters and
> resubmit the patches.

Yes.

We cannot allow drivers to keep adding unique ways to configure these
things.

There has to be a generic, consistent, mechanism the user can use
to control these parameters.  Rather than a per-driver unique one.
