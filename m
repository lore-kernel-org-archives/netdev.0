From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] selftests: correct define in msg_zerocopy.c
Date: Fri, 1 Sep 2017 09:33:05 -0700
Message-ID: <58259548-75f4-ddbf-6812-d74f5d0b16e2@fb.com>
References: <20170901163151.106867-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <dmm@fb.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:53828 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752005AbdIAQdT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:33:19 -0400
In-Reply-To: <20170901163151.106867-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/1/17 9:31 AM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> The msg_zerocopy test defines SO_ZEROCOPY if necessary, but its value
> is inconsistent with the one in asm-generic.h. Correct that.
>
> Also convert one error to a warning. When the test is complete, report
> throughput and close cleanly even if the process did not wait for all
> completions.
>
> Reported-by: Dan Melnic <dmm@fb.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Thanks for quick fixes!
Acked-by: Alexei Starovoitov <ast@kernel.org>
