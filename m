From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 1/2] bpf: add a bpf_override_function helper
Date: Wed, 1 Nov 2017 10:18:02 -0700
Message-ID: <1b1ea1f7-14ff-9725-c481-6ca6059d6051@fb.com>
References: <1509555643-2899-1-git-send-email-josef@toxicpanda.com>
 <1509555643-2899-2-git-send-email-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Josef Bacik <jbacik@fb.com>
To: Josef Bacik <josef@toxicpanda.com>, <rostedt@goodmis.org>,
        <mingo@redhat.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <ast@kernel.org>, <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46848 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751347AbdKARS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:18:27 -0400
In-Reply-To: <1509555643-2899-2-git-send-email-josef@toxicpanda.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/1/17 10:00 AM, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
>
> Error injection is sloppy and very ad-hoc.  BPF could fill this niche
> perfectly with it's kprobe functionality.  We could make sure errors are
> only triggered in specific call chains that we care about with very
> specific situations.  Accomplish this with the bpf_override_funciton
> helper.  This will modify the probe'd callers return value to the
> specified value and set the PC to an override function that simply
> returns, bypassing the originally probed function.  This gives us a nice
> clean way to implement systematic error injection for all of our code
> paths.
>
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Both bpf and tracing bits look great to me.
Acked-by: Alexei Starovoitov <ast@kernel.org>
