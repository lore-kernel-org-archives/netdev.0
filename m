From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add test for the verifier equal logic bug
Date: Wed, 30 Nov 2016 14:52:13 -0500 (EST)
Message-ID: <20161130.145213.1255113466074431974.davem@davemloft.net>
References: <1480440919-3252-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, jannh@google.com,
        daniel@iogearbox.net, kernel-team@fb.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41016 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753868AbcK3TwO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:52:14 -0500
In-Reply-To: <1480440919-3252-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Tue, 29 Nov 2016 12:35:19 -0500

> This is a test to verify that
> 
> bpf: fix states equal logic for varlen access
> 
> actually fixed the problem.  The problem was if the register we added to our map
> register was UNKNOWN in both the false and true branches and the only thing that
> changed was the range then we'd incorrectly assume that the true branch was
> valid, which it really wasnt.  This tests this case and properly fails without
> my fix in place and passes with it in place.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Applied.
