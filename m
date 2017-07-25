From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Tue, 25 Jul 2017 13:57:45 +0200
Message-ID: <20170725115745.bbguoecrcsfhbm7f@torres.zugschlus.de>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
 <1500905950.2458.6.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:38678 "EHLO
        torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdGYL5q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 07:57:46 -0400
Content-Disposition: inline
In-Reply-To: <1500905950.2458.6.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paolo,

thanks for your answer. I appreciate that.

On Mon, Jul 24, 2017 at 04:19:10PM +0200, Paolo Abeni wrote:
> On Mon, 2017-07-24 at 14:09 +0200, Marc Haber wrote:
> > Before I begin running older kernels on productive systems, I would like
> > to ask wether there have been recent changes in the 4.11 => 4.12
> > development cycle that might cause an issue like that.
> 
> While there has been some activity regarding the UDP protocol lately,
> almost nothing touched UDP in the 4.11 release cycle.

4.11 is good, 4.12 is bad.

> The issue you describe looks similar to the bug fixed by the commit
> 9bd780f5e066 ("udp: fix poll()"), but the bugged code is only in later
> kernels. 

That one is in v4.13-rc1 and v4.13-rc2, but it doesn't apply to my 4.12
trees.

> > Any idea what might be happening here and what else I could try?
> 
> Once that a system enter the buggy status, do the packets reach the
> relevant socket's queue?
> 
> ss -u

That one only shows table headers on an unaffected system in normal
operation, right?

> nstat |grep -e Udp -e Ip
> 
> will help checking that.

An unaffected system will show UdpInDatagrams, right?

But where is the connection to the relevant socket's queue?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
