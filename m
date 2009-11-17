From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 5/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 17 Nov 2009 08:35:41 -0800
Message-ID: <20091117083541.69e1e403@nehalam>
References: <200911130346.nAD3kquT001065@blc-10-10.brocade.com>
	<20091112210751.06e2d3c6@nehalam>
	<CBE1CC7A31453F4CA63C13EFCE6A0F6C05BAD1DD1B@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34772 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876AbZKQQgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 11:36:02 -0500
In-Reply-To: <CBE1CC7A31453F4CA63C13EFCE6A0F6C05BAD1DD1B@HQ-EXCH-7.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 00:32:45 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> > +
> > +#define wwn_t u64
> > +#define lun_t u64
> 
> "No need for obfuscation, at least use a typedef."
> 
> Hi Stephen,
> 
> When using a typedef in place of #define for wwn_t we are getting check-patch warning. Is it advisable to use a typedef?
> 
> - Rasesh

People disagree but my opinion on typedef's is they are ok as long as:
  * a structure or integral type (ie not a pointer)
  * encapsulates some semantic meaning (be32, spin_lock, irq_return)
  * used in several places
  * not just a data structure

The other option is just do a global replace.

What you were doing with #define is a weaker form of typedef. Which
is worse.

-- 
