From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: filter: remove unused variable and fix
 warning
Date: Mon, 30 Oct 2017 14:56:49 -0700
Message-ID: <20171030215647.q7ne77klpc74qh5b@ast-mbp>
References: <20171030204647.854-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net, Lawrence Brakmo <brakmo@fb.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:47789 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751700AbdJ3V4w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:56:52 -0400
Received: by mail-pg0-f65.google.com with SMTP id r25so12825186pgn.4
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:56:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171030204647.854-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 01:46:47PM -0700, Jakub Kicinski wrote:
> bpf_getsockopt bpf call sets the ret variable to zero and
> never changes it.  What's worse in case CONFIG_INET is
> not selected the variable is completely unused generating
> a warning.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
