From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] additional ipsec audit patch
Date: Thu, 30 Nov 2006 19:03:45 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611301902400.11407@d.namei>
References: <200611292348.kATNmfMa001526@faith.austin.ibm.com>
 <XMMS.LNX.4.64.0611291918530.28053@d.namei>  <XMMS.LNX.4.64.0611291932200.28199@d.namei>
 <1164930276.17737.530.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:59604 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S967995AbWLAADr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 19:03:47 -0500
To: Joy Latten <latten@austin.ibm.com>
In-Reply-To: <1164930276.17737.530.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Nov 2006, Joy Latten wrote:

> I ran a stress test overnight using labeled ipsec on a patched lspp55 kernel 
> using racoon last week.
> 
> The additional patch to xfrm_state.c was my fault when rebasing to
> 2.6.19-rc6 to send upstream. I plan to run an ipv4 and ipv6 stress test
> tonight and tomorrow using labeled ipsec with auditing enabled on the
> lspp56 kernel, which contains ipsec audit patch, to ensure no regression
> has occurred. I can also run an ipv4 and ipv6 stress tests
> with regular ipsec over the weekend for further ensurance.   
> 
> I compiled and did unit test with SELINUX disabled, AUDITSYSCALL
> disabled, and with both enabled. 

Thanks, applied to 

git://git.infradead.org/~jmorris/selinux-net-2.6.20#for-akpm

might be worth having it in -mm for a bit.




-- 
James Morris
<jmorris@namei.org>
