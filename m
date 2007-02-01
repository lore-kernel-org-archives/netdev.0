From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: spidernet: add improved phy support in sungem_phy.c
Date: Thu, 1 Feb 2007 11:55:48 +0100
Message-ID: <200702011155.48664.jens@de.ibm.com>
References: <200701261407.48237.jens@de.ibm.com> <20070126233809.GA16660@electric-eye.fr.zoreil.com> <20070130223050.GE5616@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, jgarzik@pobox.com,
	James K Lewis <jim@jklewis.com>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:45315 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422794AbXBAKzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 05:55:51 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l11AtnNu102806
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 10:55:49 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l11Atn7E1573072
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 11:55:49 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l11AtmO4028548
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 11:55:49 +0100
In-Reply-To: <20070130223050.GE5616@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 30 January 2007 11:30 pm, Linas Vepstas wrote:

> Shifting to the right by 5 bits has no effect on the result
> of this conditional. Either the bit is set, or its not.
> There is no need to shift.
> 
> > +	if ( (phy_reg & 0x0020) >> 7 ) {

You are right, I corrected this.

> The result here will always be zero, since the bit,
> if set, will be shifted off the end. Bits on the lef
> are padded with zero.  Ergo, this is a bug.

You are right, wrong bit. I corrected this.

Jens
