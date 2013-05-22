From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static
 inline
Date: Wed, 22 May 2013 12:03:23 -0400 (EDT)
Message-ID: <703447758.6014383.1369238603475.JavaMail.root@redhat.com>
References: <1368750099-14086-3-git-send-email-amwang@redhat.com> <20130517.141327.2084320693913331713.davem@davemloft.net> <1369198453.5722.12.camel@cr0> <20130522.001453.864958570289931561.davem@davemloft.net> <1369218521.5097.20.camel@cr0> <CAF1J0HNZS_s9pA1jetaFHZgqdgT+BfS6wASDpTL5UV8SzpH6Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:55491 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348Ab3EVQDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 12:03:25 -0400
In-Reply-To: <CAF1J0HNZS_s9pA1jetaFHZgqdgT+BfS6wASDpTL5UV8SzpH6Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> 
> I think you can just drop #ifdefs in 90% of the cases rather than
> create two versions of code for IPv4 and IPv6....
> 

I know we can use memcmp(), but comparing 16+ bytes even for IPv4 is not
a good idea, also we have to zalloc() every instance of union vxlan_addr.
