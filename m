From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net: filter: remove unused variable and fix
 warning
Date: Mon, 30 Oct 2017 22:55:14 +0100
Message-ID: <59F79FC2.6010402@iogearbox.net>
References: <20171030204647.854-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Lawrence Brakmo <brakmo@fb.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51505 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751700AbdJ3VzS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:55:18 -0400
In-Reply-To: <20171030204647.854-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2017 09:46 PM, Jakub Kicinski wrote:
> bpf_getsockopt bpf call sets the ret variable to zero and
> never changes it.  What's worse in case CONFIG_INET is
> not selected the variable is completely unused generating
> a warning.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
