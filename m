From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 2/7] bpf: Allow cgroup sock filters to use
 get_current_uid_gid helper
Date: Fri, 01 Sep 2017 00:22:25 +0200
Message-ID: <59A88C21.5070702@iogearbox.net>
References: <1504217150-16151-1-git-send-email-dsahern@gmail.com> <1504217150-16151-3-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
        ast@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44314 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdHaWW1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:22:27 -0400
In-Reply-To: <1504217150-16151-3-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 12:05 AM, David Ahern wrote:
> Allow BPF programs run on sock create to use the get_current_uid_gid
> helper. IPv4 and IPv6 sockets are created in a process context so
> there is always a valid uid/gid
>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
