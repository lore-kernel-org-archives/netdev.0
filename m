From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: small packets sent through ne2k-pci delayed
Date: Sun, 4 Apr 2010 10:23:42 -0700 (PDT)
Message-ID: <4059442.59771270401822892.JavaMail.root@tahiti.vyatta.com>
References: <27697562.59751270401801591.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: p gortmaker <p_gortmaker@yahoo.com>, netdev@vger.kernel.org
To: Florian Zumbiehl <florz@florz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32964 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751613Ab0DDRYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Apr 2010 13:24:04 -0400
In-Reply-To: <27697562.59751270401801591.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- "Florian Zumbiehl" <florz@florz.de> wrote:

> Hi,
> 
> I noticed today that a 2.6.33 kernel with an ne2k-pci card of mine
> transmits small packets (those that result in frames < 61 bytes)
> only with some major delay - or more exactly, it seems that they are
> being transmitted only when the next packet to be transmitted comes
> along.
> 
> Now, this patch seems to fix it for me, but I am not that sure that
> that's
> how it should be fixed:
> 
> di

> I _think_ that this problem did not exist with 2.6.22-rc4 - but I
> didn't
> have a chance to (re-)test that yet, I just think that I did things in
> the
> past (when that kernel was still running on that machine) that would
> imply
> that the problem did not exist at the time ...
> 
> So, any suggestions what I should try, other than re-testing with
> 2.6.22-rc4 (some time soon, I can do that, too, just not now)?
> 
> What might be interesting to know: those 61-byte frames do actually
> arrive
> at the recipient as 61-byte frames ...
> 
> Florian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The standard correct way to do this is skb_padto()
