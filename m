From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH 1/1] additional ipsec audit patch
Date: Thu, 30 Nov 2006 17:44:36 -0600
Message-ID: <1164930276.17737.530.camel@faith.austin.ibm.com>
References: <200611292348.kATNmfMa001526@faith.austin.ibm.com>
	 <XMMS.LNX.4.64.0611291918530.28053@d.namei>
	 <XMMS.LNX.4.64.0611291932200.28199@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:61595 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S966999AbWK3X6J
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 18:58:09 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAUNw8TK020312
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 18:58:08 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAUNw870538730
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 16:58:08 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAUNw7IO028498
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 16:58:08 -0700
To: James Morris <jmorris@namei.org>
In-Reply-To: <XMMS.LNX.4.64.0611291932200.28199@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-29 at 19:32 -0500, James Morris wrote:
> On Wed, 29 Nov 2006, James Morris wrote:
> 
> > On Wed, 29 Nov 2006, Joy Latten wrote:
> > 
> > > This patch disables auditing in ipsec when CONFIG_AUDITSYSCALL is
> > > disabled in the kernel. 
> > > 
> > > This patch also includes a bug fix for xfrm_state.c as a result of
> > > original ipsec audit patch.
> > > 
> > > Let me know if it looks ok.
> > 
> > 
> > Also, the last patch contains no Signed-off-by: line, please resend.
> 
> And, what is the testing status of these patches?
> 
I ran a stress test overnight using labeled ipsec on a patched lspp55 kernel 
using racoon last week.

The additional patch to xfrm_state.c was my fault when rebasing to
2.6.19-rc6 to send upstream. I plan to run an ipv4 and ipv6 stress test
tonight and tomorrow using labeled ipsec with auditing enabled on the
lspp56 kernel, which contains ipsec audit patch, to ensure no regression
has occurred. I can also run an ipv4 and ipv6 stress tests
with regular ipsec over the weekend for further ensurance.   

I compiled and did unit test with SELINUX disabled, AUDITSYSCALL
disabled, and with both enabled. 

regards,
Joy
