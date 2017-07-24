From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Mon, 24 Jul 2017 16:19:10 +0200
Message-ID: <1500905950.2458.6.camel@redhat.com>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Marc Haber <mh+netdev@zugschlus.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49454 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932079AbdGXOTM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 10:19:12 -0400
In-Reply-To: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 2017-07-24 at 14:09 +0200, Marc Haber wrote:
> Before I begin running older kernels on productive systems, I would like
> to ask wether there have been recent changes in the 4.11 => 4.12
> development cycle that might cause an issue like that.

While there has been some activity regarding the UDP protocol lately,
almost nothing touched UDP in the 4.11 release cycle.

The issue you describe looks similar to the bug fixed by the commit
9bd780f5e066 ("udp: fix poll()"), but the bugged code is only in later
kernels. 

> Any idea what might be happening here and what else I could try?

Once that a system enter the buggy status, do the packets reach the
relevant socket's queue?

ss -u
nstat |grep -e Udp -e Ip

will help checking that.

Thanks,

Paol
