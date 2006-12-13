From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] add init_dummy_netdev() for napi only dummy intefaces
Date: Wed, 13 Dec 2006 13:06:23 -0800
Message-ID: <20061213130623.0d1153b7@dxpl.pdx.osdl.net>
References: <1165901258.11914.32.camel@localhost.localdomain>
	<20061213113537.6baf410f@dxpl.pdx.osdl.net>
	<1166042552.11914.188.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:41802 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958AbWLMVG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 16:06:29 -0500
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1166042552.11914.188.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 07:42:32 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Wed, 2006-12-13 at 11:35 -0800, Stephen Hemminger wrote:
> 
> > Could we split off the NAPI context part of network_device instead?
> > I'll work up something for 2.6.21.
> 
> That would do the trick too... though I prefer not putting my hands in
> network_device too much myself :-)
> 
> Ben
> 

There are other cases that need it as well (like backlog_device)
