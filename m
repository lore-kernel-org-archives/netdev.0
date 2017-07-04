From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix return in load_bpf_file
Date: Wed, 05 Jul 2017 00:14:46 +0200
Message-ID: <595C1356.3000508@iogearbox.net>
References: <20170704215129.4047623-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Alexei Starovoitov <ast@fb.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47266 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752239AbdGDWOs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 18:14:48 -0400
In-Reply-To: <20170704215129.4047623-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/04/2017 11:51 PM, Lawrence Brakmo wrote:
> The function load_bpf_file ignores the return value of
> load_and_attach(), so even if load_and_attach() returns an error,
> load_bpf_file() will return 0.
>
> Now, load_bpf_file() can call load_and_attach() multiple times and some
> can succeed and some could fail. I think the correct behavor is to
> return error on the first failed load_and_attach().

Your SOB is missing.
