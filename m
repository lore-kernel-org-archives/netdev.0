From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Tue, 2 May 2006 11:08:14 +0400
Message-ID: <20060502070814.GA9557@2ka.mipt.ru>
References: <20060428195930.GB21294@2ka.mipt.ru> <20060428.150056.18940876.davem@davemloft.net> <20060429124451.GA19810@2ka.mipt.ru> <20060501.143246.112559350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: shemminger@osdl.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:26832 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932139AbWEBHIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 03:08:47 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060501.143246.112559350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 01, 2006 at 02:32:46PM -0700, David S. Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Sat, 29 Apr 2006 16:44:51 +0400
> 
> > Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> I understand how in some ways this is work in progress,
> but direct calls into ext3 from the kevent code?  I'd
> like stuff like that cleaned up before reviewing :-)

Well, this only requires per address space ->get_block() callback,
which is what ext3_get_block() is.

I will update and resend patchset today.

Thank you.

-- 
	Evgeniy Polyakov
