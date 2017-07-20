From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net 1/5] bpf: fix mixed signed/unsigned derived min/max
 value bounds
Date: Thu, 20 Jul 2017 15:19:26 -0700
Message-ID: <9f074fe7-1d9c-97e0-c1a6-bcaa32a0e7c8@fb.com>
References: <cover.1500586732.git.daniel@iogearbox.net>
 <463af4df5faf0a06ef9d8131727bb50eac8a7bf8.1500586732.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ecree@solarflare.com>, <josef@toxicpanda.com>,
        <netdev@vger.kernel.org>, Josef Bacik <jbacik@fb.com>,
        Martin KaFai Lau <kafai@fb.com>, Yonghong Song <yhs@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44063 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934851AbdGTWTv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 18:19:51 -0400
In-Reply-To: <463af4df5faf0a06ef9d8131727bb50eac8a7bf8.1500586732.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/20/17 3:00 PM, Daniel Borkmann wrote:
> Edward reported that there's an issue in min/max value bounds
> tracking when signed and unsigned compares both provide hints
> on limits when having unknown variables. E.g. a program such
> as the following should have been rejected:

Thanks a lot for the hard work you folks have put into this set.

Acked-by: Alexei Starovoitov <ast@kernel.org>
