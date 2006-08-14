From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-rc3-mm2 (+ hotfixes): GPF related to skge on suspend
Date: Sun, 13 Aug 2006 18:06:02 -0700
Message-ID: <20060813180602.630e60e3.akpm@osdl.org>
References: <20060813173503.e009583c.akpm@osdl.org>
	<17555.1155516861@ocs10w.ocs.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <76306.1226@compuserve.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@osdl.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59112 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751341AbWHNBGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2006 21:06:25 -0400
To: Keith Owens <kaos@ocs.com.au>
In-Reply-To: <17555.1155516861@ocs10w.ocs.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Aug 2006 10:54:21 +1000
Keith Owens <kaos@ocs.com.au> wrote:

> >Code: 44 8b 28 c7 45 d0 00 00 00 00 45 85 ed 0f 89 29 fb ff ff e9
> >Error (Oops_bfd_perror): /tmp/ksymoops.0lrVNY Invalid bfd target
> >
> >box:/home/akpm> rpm -qi ksymoops 
> >Name        : ksymoops                     Relocations: (not relocatable)
> >Version     : 2.4.11                            Vendor: (none)
> >Release     : 1                             Build Date: Sat Jan  8 05:43:45 2005
> >Install Date: Wed Jun 28 16:59:45 2006      Build Host: ocs3.ocs.com.au
> >Group       : Utilities/System              Source RPM: ksymoops-2.4.11-1.src.rpm
> 
> Back in 2000 there were a lot of version problems between ksymoops and
> libbfd and libiberty, so I statically link against these libraries when
> I build the rpm.  You have an i386 version of ksymoops, which was built
> against an i386 only version of libbfd, it does not support target
> elf64-x86-64.  Grab the ksymoops src.rpm and rebuild on x86_64, or use
> a binary rpm from an x86_64 distribution.

But would such a binary be able to decode i386 oopses?

ftp://ftp.kernel.org/pub/linux/utils/kernel/ksymoops/v2.4/ksymoops-2.4.11-1.src.rpm
fails to build, btw.  Had to do s/Copyright/License/ in the spec file.

