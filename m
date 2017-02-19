From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net 0/4] update ipvs sysctl document
Date: Sun, 19 Feb 2017 16:04:54 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1702191552560.1590@ja.home.ssi.bg>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59994 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750847AbdBSOFL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 09:05:11 -0500
In-Reply-To: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 17 Feb 2017, Hangbin Liu wrote:

> Fix and add some new ipvs sysctl options. Also use tab instead of whitespaces
> to indent the descriptions.

	You change only docs, so the patchset should be for
the net-next tree.

> Hangbin Liu (4):
>   ipvs: fix sync_threshold description and add sync_refresh_period,
>     sync_retries
>   ipvs: Document sysctl sync_qlen_max and sync_sock_size

- we can add "are " here but then also check if lines become too long:

"Hard limit for queued sync messages that [are ]not sent yet."

	You can also move the "commit" word to next line
to make checkpatch happy:

scripts/checkpatch.pl --strict /tmp/file2.patch

>   ipvs: Document sysctl sync_ports
>   ipvs: Document sysctl pmtu_disc

- we can make it like this:

"By default, reject with FRAG_NEEDED all DF packets that exceed
the PMTU, irrespective of the forwarding method. For TUN method
the flag can be disabled to fragment such packets."

>  Documentation/networking/ipvs-sysctl.txt | 68 ++++++++++++++++++++++++++++----
>  1 file changed, 60 insertions(+), 8 deletions(-)

Regards
