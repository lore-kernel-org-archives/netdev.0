From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bpf: Fix number of retries when
 growing log buffer
Date: Fri, 9 Dec 2016 12:42:49 -0800
Message-ID: <20161209124249.0ffc0a25@xeon-e3>
References: <fc3866340db64ff7400c14342578b9a104f02fe9.1481103964.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34858 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750756AbcLIUm5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 15:42:57 -0500
Received: by mail-pg0-f53.google.com with SMTP id p66so11290774pga.2
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 12:42:57 -0800 (PST)
In-Reply-To: <fc3866340db64ff7400c14342578b9a104f02fe9.1481103964.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Dec 2016 10:47:59 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> The log buffer is automatically grown when the verifier output does not
> fit into the default buffer size. The number of growing attempts was
> not sufficient to reach the maximum buffer size so far.
> 
> Perform 9 iterations to reach max and let the 10th one fail.
> 
> j:0     i:65536         max:16777215
> j:1     i:131072        max:16777215
> j:2     i:262144        max:16777215
> j:3     i:524288        max:16777215
> j:4     i:1048576       max:16777215
> j:5     i:2097152       max:16777215
> j:6     i:4194304       max:16777215
> j:7     i:8388608       max:16777215
> j:8     i:16777216      max:16777215
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied to net-next
