From: Paolo Pisati <p.pisati@gmail.com>
Subject: Re: [PATCH 0/6] kernel parameters: introduce "macaddr" to set mac
 address
Date: Wed, 24 Oct 2012 10:07:54 +0200
Message-ID: <20121024080754.GA4443@newluxor>
References: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
 <20121023.132037.2010164496712539552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: p.pisati@gmail.com, netdev@vger.kernel.org, peppe.cavallaro@st.com,
	kristoffer@gaisler.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:33693 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757965Ab2JXIIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 04:08:05 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so226353wgb.1
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2012 01:08:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20121023.132037.2010164496712539552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 23, 2012 at 01:20:37PM -0400, David Miller wrote:
> From: Paolo Pisati <p.pisati@gmail.com>
> Date: Tue, 23 Oct 2012 19:15:27 +0200
> 
> > In the past drivers grew mechanism to set their own mac address at boot time
> > via (usually) a module parameter. Unfortunately every single driver had its
> > own naming/implementation and it soon became clear that a generic
> > mechanism was needed.
> > 
> > Introduce "macaddr=", a new kernel parameter to set MAC address using
> > netdevice ops (and hence being hardware independent).
> 
> Sorry, no, no module parameters.
> 
> Run time setting is the only reasonable way to set the MAC address
> explicitly.

actually it's a not a module parameter.

and what if you want to change your nic MAC at boot time? e.g. netboot
setup with different configs per different MACs.
-- 
bye,
p.
