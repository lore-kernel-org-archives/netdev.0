From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH iproute2 net 0/8] tc/act_pedit: Support offset relative
 to conventional header
Date: Wed, 3 May 2017 09:27:31 +0300
Message-ID: <20170503062731.GA28834@office.localdomain>
References: <20170423125356.1298-1-amir@vadai.me>
 <20170501092625.30274bee@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34851 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdECG1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 02:27:36 -0400
Received: by mail-wm0-f65.google.com with SMTP id d79so10157951wmi.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 23:27:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170501092625.30274bee@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 01, 2017 at 09:26:25AM -0700, Stephen Hemminger wrote:
> On Sun, 23 Apr 2017 15:53:48 +0300
> Amir Vadai <amir@vadai.me> wrote:
> 
> > Hi Stephen,
> > 
> > This patchset extends pedit to support modifying a field in an offset relative
> > to the conventional network headers (kenrel support was added [1] in 4.11 rc1).
> > Without the extended pedit, user could specify fields in TCP and ICMP headers,
> > but the kernel code was using an offset relative to the begining of the IP
> > header. This will break if IP header length is greater than the minimal value
> > of 20, or if L3 is not IPv4.
> > 
> > It also introduces support in manipulating ETH, TCP, UDP and IP.ttl fields and
> > a new command to increase/decrease the value of a field (current use case is IP.ttl).
> > 
> > Since there might be deployments already using pedit, special consideration was
> > taken, not to break those scripts - only by specifying the special keyword
> > 'ex', the extended capabilities are available, thus there should be no impact
> > on existing scripts.
> > Also, the new code can live together with rules added by the old code. It
> > supports both the old netlink and the new one.
> > 
> > This patchset is against the master and not net-next as the functionality was
> > added in 4.11
> > 
> > Thanks,
> > Amir
> > 
> > [1] - 71d0ed7079df ("net/act_pedit: Support using offset relative to the
> >                      conventional network headers")

[...]

> 
> Applied. Then I cleaned up long lines

Thanks. Will make sure to clean up long lines in future patches.
