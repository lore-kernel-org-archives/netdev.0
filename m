From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/7] bpf: Add strict alignment flag for
 BPF_PROG_LOAD.
Date: Thu, 11 May 2017 12:43:28 -0400 (EDT)
Message-ID: <20170511.124328.2245042886705281468.davem@davemloft.net>
References: <20170511.120540.405652687533650995.davem@davemloft.net>
        <a1a33bb6-c230-3748-a192-9479d5d4fa2d@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755698AbdEKQn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:43:29 -0400
In-Reply-To: <a1a33bb6-c230-3748-a192-9479d5d4fa2d@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 11 May 2017 17:18:30 +0100

> On 11/05/17 17:05, David Miller wrote:
>> Add a new field, "prog_flags", and an initial flag value
>> BPF_F_STRCIT_ALIGNMENT.
> Should this be STRICT?

Indeed, thanks for catching that typo.
