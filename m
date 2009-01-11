From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 4/4] net: ppp_generic - introduce net-namespace
 functionality
Date: Sat, 10 Jan 2009 23:39:12 -0800 (PST)
Message-ID: <20090110.233912.19825434.davem@davemloft.net>
References: <20090110092258.GA7622@localhost>
	<20090110092830.GB7622@localhost>
	<18793.15953.591733.958862@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
To: paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38397
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751065AbZAKHjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 02:39:12 -0500
In-Reply-To: <18793.15953.591733.958862@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Mackerras <paulus@samba.org>
Date: Sun, 11 Jan 2009 11:33:21 +1100

> Cyrill Gorcunov writes:
> 
> > From: Cyrill Gorcunov <gorcunov@gmail.com>
> > Subecjt: [RFC] net: ppp_generic - introduce net-namespace functionality
> > 
> > - Each namespace contain ppp channels and units separately
> >   with appropriate locks
> 
> This looks like a lot of uglification to me.  Why exactly do
> individual network drivers need to know or care about namespaces?

They need to know if there is a lookup involved and the device
type internally has it's own realm of keys that identify such
devices.

PPP fits that particular case.
