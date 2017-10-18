From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] bpf: move context info out of the verifier
Date: Wed, 18 Oct 2017 14:17:30 +0100 (WEST)
Message-ID: <20171018.141730.574848172888041325.davem@davemloft.net>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbdJRNRk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 09:17:40 -0400
In-Reply-To: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 16 Oct 2017 16:40:52 -0700

> Daniel pointed out during the review of my previous patchset that
> the knowledge about context doesn't really belong directly in the
> verifier.  This patch set takes a bit of a drastic approach to
> move the info out of there.  I want to be able to use different
> set of verifier_ops for program analysis.  To do that, I have
> to first move the test_run callback to a separate structure.  Then
> verifier ops can be declared in the verifier directly and
> different sets can be picked for verification vs analysis.

Series applied, thanks.
