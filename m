From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 3/7] bpf: Add strict alignment flag for BPF_PROG_LOAD.
Date: Thu, 11 May 2017 17:18:30 +0100
Message-ID: <a1a33bb6-c230-3748-a192-9479d5d4fa2d@solarflare.com>
References: <20170511.120540.405652687533650995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <alexei.starovoitov@gmail.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:34757 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932473AbdEKQTB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:19:01 -0400
In-Reply-To: <20170511.120540.405652687533650995.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/17 17:05, David Miller wrote:
> Add a new field, "prog_flags", and an initial flag value
> BPF_F_STRCIT_ALIGNMENT.
Should this be STRICT?
