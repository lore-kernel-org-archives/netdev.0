From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Mainline kernel OLTP performance update
Date: Mon, 26 Jan 2009 12:36:05 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0901261235270.1908@qirst.com>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>  <200901161503.13730.nickpiggin@yahoo.com.au>  <20090115201210.ca1a9542.akpm@linux-foundation.org>  <200901161746.25205.nickpiggin@yahoo.com.au>  <20090116065546.GJ31013@parisc-linux.org>
  <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>  <1232428583.11429.83.camel@ymzhang>  <alpine.DEB.1.10.0901211852060.18367@qirst.com>  <1232613395.11429.122.camel@ymzhang>  <1232615707.14549.6.camel@penberg-laptop>
 <1232616517.11429.129.camel@ymzhang>  <1232617672.14549.25.camel@penberg-laptop>  <1232679773.11429.155.camel@ymzhang>  <4979692B.3050703@cs.helsinki.fi>  <1232697998.6094.17.camel@penberg-laptop>  <1232699401.11429.163.camel@ymzhang>
 <1232703989.6094.29.camel@penberg-laptop>  <alpine.DEB.1.10.0901231020030.21692@qirst.com> <1232765728.11429.193.camel@ymzhang>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com, Ingo Molnar <mingo@elte.hu>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:42023 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbZAZR5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:57:34 -0500
In-Reply-To: <1232765728.11429.193.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 24 Jan 2009, Zhang, Yanmin wrote:

> But when trying to increased it to 4, I got:
> [root@lkp-st02-x8664 slab]# echo "3">kmalloc-8192/order
> [root@lkp-st02-x8664 slab]# echo "4">kmalloc-8192/order
> -bash: echo: write error: Invalid argument

This is because 4 is more than the maximum allowed order. You can
reconfigure that by setting

slub_max_order=5

or so on boot.
