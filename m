From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] security: bpf: replace include of linux/bpf.h
 with forward declarations
Date: Thu, 02 Nov 2017 16:50:39 +0900 (KST)
Message-ID: <20171102.165039.66644713666416817.davem@davemloft.net>
References: <20171101184800.16416-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        fengc@google.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44852 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755212AbdKBHuo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:50:44 -0400
In-Reply-To: <20171101184800.16416-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed,  1 Nov 2017 11:48:00 -0700

> Touching linux/bpf.h makes us rebuild a surprisingly large
> portion of the kernel.  Remove the unnecessary dependency
> from security.h, it only needs forward declarations.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>

Applied.
