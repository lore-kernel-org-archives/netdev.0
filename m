From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] bpf: expose prog id for cls_bpf and act_bpf
Date: Wed, 21 Jun 2017 14:09:10 -0700
Message-ID: <20170621210901.xzzmpbjuboii7v7i@kafai-mba.local>
References: <66b50f95666de97e7f067471d409fce8d316ad43.1498068442.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <john.fastabend@gmail.com>,
        <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50793 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751093AbdFUVJd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 17:09:33 -0400
Content-Disposition: inline
In-Reply-To: <66b50f95666de97e7f067471d409fce8d316ad43.1498068442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 08:16:11PM +0200, Daniel Borkmann wrote:
> In order to be able to retrieve the attached programs from cls_bpf
> and act_bpf, we need to expose the prog ids via netlink so that
> an application can later on get an fd based on the id through the
> BPF_PROG_GET_FD_BY_ID command, and dump related prog info via
> BPF_OBJ_GET_INFO_BY_FD command for bpf(2).
Acked-by: Martin KaFai Lau <kafai@fb.com>
