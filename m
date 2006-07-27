From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: RFC: kernel memory leak fix for af_unix datagram getpeersec
Date: Thu, 27 Jul 2006 15:22:16 -0400
Message-ID: <OF4EC0606D.E357EE61-ON852571B8.006A5AAE-852571B8.006A68C9@us.ibm.com>
References: <b0943d9e0607270200h250953d7uf58dc9a4f087cb0b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "Catherine Zhang" <cxzhang@watson.ibm.com>, czhang.us@gmail.com,
	davem@davemloft.net, jmorris@namei.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	netdev@vger.kernel.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45291 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751027AbWG0TWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 15:22:20 -0400
In-Reply-To: <b0943d9e0607270200h250953d7uf58dc9a4f087cb0b@mail.gmail.com>
To: "Catalin Marinas" <catalin.marinas@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Catalin and Michal,

Many thanks for your help in fnding and testing the patch!

Catherine

"Catalin Marinas" <catalin.marinas@gmail.com> wrote on 07/27/2006 05:00:23 
AM:

> On 26/07/06, Catherine Zhang <cxzhang@watson.ibm.com> wrote:
> > Enclosed please find the new fix for the memory leak problem, 
incorporating
> > suggestions from Stephen and James.
> 
> FYI, Michal confirmed that, with this patch, kmemleak no longer
> reports leaks in the context_struct_to_string() function in
> security/selinux/ss/services.c. Many thanks to Michal for testing this
> (and his constant feedback into kmemleak).
> 
> -- 
> Catalin

