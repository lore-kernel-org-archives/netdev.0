From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 3/3] bpf: Test deletion in BPF_MAP_TYPE_LPM_TRIE
Date: Mon, 18 Sep 2017 15:54:59 -0700
Message-ID: <a3f50adb-381b-65ff-2c80-cf3dadbbe248@fb.com>
References: <20170918193057.37644-1-kraigatgoog@gmail.com>
 <20170918193057.37644-4-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>,
        Daniel Mack <daniel@zonque.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55502 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750747AbdIRWzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 18:55:48 -0400
In-Reply-To: <20170918193057.37644-4-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/18/17 12:30 PM, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
>
> Extend the 'random' operation tests to include a delete operation
> (delete half of the nodes from both lpm implementions and ensure
> that lookups are still equivalent).
>
> Also, add a simple IPv4 test which verifies lookup behavior as nodes
> are deleted from the tree.
>
> Signed-off-by: Craig Gallek <kraig@google.com>

Thanks for the tests!
Acked-by: Alexei Starovoitov <ast@kernel.org>
