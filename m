From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: filter: remove unused variable and fix
 warning
Date: Tue, 31 Oct 2017 09:26:17 +0900 (KST)
Message-ID: <20171031.092617.2111347698985537698.davem@davemloft.net>
References: <20171030204647.854-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net, brakmo@fb.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753359AbdJaA0V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 20:26:21 -0400
In-Reply-To: <20171030204647.854-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 30 Oct 2017 13:46:47 -0700

> bpf_getsockopt bpf call sets the ret variable to zero and
> never changes it.  What's worse in case CONFIG_INET is
> not selected the variable is completely unused generating
> a warning.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>

Applied.
