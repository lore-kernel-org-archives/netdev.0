From: James Morris <james.l.morris@oracle.com>
Subject: Re: [RFC PATCH 1/5] security: Add support for SCTP security hooks
Date: Fri, 20 Oct 2017 15:53:03 +1100 (AEDT)
Message-ID: <alpine.LFD.2.20.1710201551200.4174@t440>
References: <20171017140247.4604-1-richard_c_haines@btinternet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-security-module@vger.kernel.org,
        paul@paul-moore.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
        sds@tycho.nsa.gov, eparis@parisplace.org, marcelo.leitner@gmail.com
To: Richard Haines <richard_c_haines@btinternet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37063 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750773AbdJTEyd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 00:54:33 -0400
In-Reply-To: <20171017140247.4604-1-richard_c_haines@btinternet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Oct 2017, Richard Haines wrote:

> The SCTP security hooks are explained in:
> Documentation/security/LSM-sctp.txt
> 
> Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
> ---
>  Documentation/security/LSM-sctp.txt | 212 ++++++++++++++++++++++++++++++++++++
>  include/linux/lsm_hooks.h           |  37 +++++++
>  include/linux/security.h            |  27 +++++
>  security/security.c                 |  23 ++++
>  4 files changed, 299 insertions(+)
>  create mode 100644 Documentation/security/LSM-sctp.txt

This looks ok from an LSM API pov, but note that I'm not an expert on 
SCTP.  It would be good to see more review from networking folk.


Reviewed-by: James Morris <james.l.morris@oracle.com>

-- 
James Morris
<james.l.morris@oracle.com>
