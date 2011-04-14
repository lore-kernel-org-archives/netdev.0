From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Thu, 14 Apr 2011 16:55:49 +0200
Message-ID: <0a7fdea6b816da546ea71f752d36b5c2@localhost>
References: <1301783301.2837.77.camel@edumazet-laptop>
 <1301784797.3110.4.camel@localhost>
 <1301838968.2837.200.camel@edumazet-laptop> <4DA70743.1050106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:48606 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758874Ab1DNOzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 10:55:53 -0400
In-Reply-To: <4DA70743.1050106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 14 Apr 2011 17:40:03 +0300, Avi Kivity <avi@redhat.com> wrote:



> Have you considered putting the compiler in userspace?



Kernelspace (modules, threads, etc) can register BPF filters too. It is

possible that there is no userspace involved at all.



> The upside is that you can use established optimizing compilers like 

> LLVM or GCC, which already support more target architectures.  It may 

> not matter much for something simple like bpf, but other VMs may be a 

> lot more complicated.



BPF is another domain. Standard compiler optimization are not comparable

to BPF optimizations so there is no gain there. Maybe writing a gcc front

_and_ back-end may gain some valuable advantages.



Hagen 
