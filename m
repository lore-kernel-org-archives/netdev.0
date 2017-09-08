From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net PATCH 2/3] bpf: add support for sockmap detach programs
Date: Fri, 8 Sep 2017 15:38:47 -0700
Message-ID: <4876e2ef-b093-cfb6-c1fd-c7f44ff891bb@fb.com>
References: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
 <150490444956.11590.4733752227675213913.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <daniel@iogearbox.net>
To: John Fastabend <john.fastabend@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55731 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753026AbdIHWjL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 18:39:11 -0400
In-Reply-To: <150490444956.11590.4733752227675213913.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/8/17 2:00 PM, John Fastabend wrote:
> The bpf map sockmap supports adding programs via attach commands. This
> patch adds the detach command to keep the API symmetric and allow
> users to remove previously added programs. Otherwise the user would
> have to delete the map and re-add it to get in this state.
>
> This also adds a series of additional tests to capture detach operation
> and also attaching/detaching invalid prog types.
>
> API note: socks will run (or not run) programs depending on the state
> of the map at the time the sock is added. We do not for example walk
> the map and remove programs from previously attached socks.
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Nice clean patch. Thx
Acked-by: Alexei Starovoitov <ast@kernel.org>
