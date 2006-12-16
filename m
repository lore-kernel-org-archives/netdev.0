From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/3] chelsio: more receive cleanup
Date: Fri, 15 Dec 2006 17:28:00 -0800
Message-ID: <20061215172800.52713c89@freekitty>
References: <20061215190716.956791000@osdl.org>
	<20061215190813.803776000@osdl.org>
	<20061215201019.GA11385@electric-eye.fr.zoreil.com>
	<20061215145533.4cda3f23@freekitty>
	<20061216002604.GA11284@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:34005 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030528AbWLPB2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 20:28:11 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061216002604.GA11284@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 16 Dec 2006 01:26:04 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> > Francois Romieu <romieu@fr.zoreil.com> wrote:
> [...]
> > Why, you can't predict copybreak on off
> 
> Plain gut feeling. I'd rather spend extra cycles on small packets (whose
> allocation is already optimized) and keep the normal packets less expensive
> on a 10Gb/s network card.
>

Likely/unlikely is an optimization that doesn't make a big difference and
I would rather the compiler choose unless it is something obvious like
an error path or external interrupt (like PHY).

There was some discussion on LKML, which I mostly forgot, that hinted that
on some architectures using likely/unlikely incorrectly could have a major
hit.


-- 
Stephen Hemminger <shemminger@osdl.org>
