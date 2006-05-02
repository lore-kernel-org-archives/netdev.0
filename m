From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 2/3] ipg: leaks in ipg_probe
Date: Tue, 02 May 2006 22:04:47 +0300
Message-ID: <1146596687.13675.1.camel@localhost>
References: <Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI>
	 <1146306567.1642.3.camel@localhost> <20060429122119.GA22160@fargo>
	 <1146342905.11271.3.camel@localhost> <1146389171.11524.1.camel@localhost>
	 <44554ADE.8030200@cantab.net> <4455F1D8.5030102@cantab.net>
	 <1146506939.23931.2.camel@localhost>
	 <20060501231050.GC7419@electric-eye.fr.zoreil.com>
	 <Pine.LNX.4.58.0605020936420.4066@sbz-30.cs.Helsinki.FI>
	 <20060502183313.GA26357@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <dvrabel@cantab.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:3822 "EHLO
	mail.cs.helsinki.fi") by vger.kernel.org with ESMTP
	id S1750809AbWEBTEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 May 2006 15:04:51 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060502183313.GA26357@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka J Enberg <penberg@cs.Helsinki.FI> :
> [...]
> > Is this tested with hardware?

On Tue, 2006-05-02 at 20:33 +0200, Francois Romieu wrote:
> No.

On Tue, 2006-05-02 at 20:33 +0200, Francois Romieu wrote:
> > Alignment of the start address looks bogus for sure, but any idea
> > why they had it in the first place?

Pekka J Enberg <penberg@cs.Helsinki.FI> :
> No clear idea but it matches the significant part of the BAR register
> for the 256 bytes of I/O space that the device uses.

OK. David & David, would appreciate if either you could give the patch a
spin with Francois' changes. Thanks.

				Pekka

