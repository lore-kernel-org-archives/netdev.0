From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl
 modules)
Date: Fri, 1 Jun 2007 14:22:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706011414490.28601@kivilampi-30.cs.helsinki.fi>
References: <20070529131951.1d9a5b84@freepuppy>
 <Pine.LNX.4.64.0705292335080.23565@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0705301206130.14736@kivilampi-30.cs.helsinki.fi>
 <20070531.213834.80026176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1301103987-1180696626=:28601"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52140 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226AbXFALW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 07:22:57 -0400
In-Reply-To: <20070531.213834.80026176.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0706011420540.28601@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1301103987-1180696626=:28601
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0706011420541.28601@kivilampi-30.cs.helsinki.fi>

On Thu, 31 May 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 30 May 2007 12:10:06 +0300 (EEST)
> 
> > [PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl modules)
> > 
> > The code used to ignore GSO completely, passing either way too
> > small or zero pkts_acked when GSO skb or part of it got ACKed.
> > In addition, there is no need to calculate the value in the loop
> > but simple arithmetics after the loop is sufficient. There is
> > no need to handle SYN case specially because congestion control
> > modules are not yet initialized when FLAG_SYN_ACKED is set.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Patch applied, thanks a lot!

...It's good to be on the alert with this one because it might uncover
some hidden bugs from congestion control module code (it changes some 
behavior so radically), which obviously will have to be then fixed
too...


-- 
 i.
---696243703-1301103987-1180696626=:28601--
