From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/3] cls_bpf: further limit exec opcodes subset
Date: Wed, 23 Sep 2015 13:54:28 -0700
Message-ID: <56031184.3030308@plumgrid.com>
References: <cover.1443037353.git.daniel@iogearbox.net>
 <30adbc348f5fcefddff51c8155086a87b389ccdb.1443037354.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36731 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbbIWUya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 16:54:30 -0400
Received: by pacgz1 with SMTP id gz1so728023pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 13:54:29 -0700 (PDT)
In-Reply-To: <30adbc348f5fcefddff51c8155086a87b389ccdb.1443037354.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/15 12:56 PM, Daniel Borkmann wrote:
> Jamal suggested to further limit the currently allowed subset of opcodes
> that may be used by a direct action return code as the intention is not
> to replace the full action engine, but rather to have a minimal set that
> can be used in the fast-path on things like ingress for some features
> that cls_bpf supports.
>
> Classifiers can, of course, still be chained together that have direct
> action mode with those that have a full exec pass. For more complex
> scenarios that go beyond this minimal set here, the full tcf_exts_exec()
> path must be used.
>
> Suggested-by: Jamal Hadi Salim<jhs@mojatatu.com>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
