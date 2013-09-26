From: Konstantin Kuzov <master.nosferatu@gmail.com>
Subject: Re: BUG: MARK in OUTPUT + ip_tunnel causes kernel panic
Date: Thu, 26 Sep 2013 06:06:04 +0400
Message-ID: <20130926060604.4838802c@gmail.com>
References: <CAKfDRXgJwyhE6sg1Ej=S35A+-dnPiU9TBA69zb-n7hGXgG+Sxg@mail.gmail.com>
	<loom.20130925T095425-819@post.gmane.org>
	<20130925085947.GY7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:64182 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314Ab3IZCHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 22:07:10 -0400
Received: by mail-la0-f48.google.com with SMTP id er20so401330lab.35
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 19:07:08 -0700 (PDT)
In-Reply-To: <20130925085947.GY7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Sep 2013 10:59:47 +0200
Steffen Klassert wrote:

 > > > When trying to tunnel traffic originating from the same machine as the
 > > > tunnel endpoint, I am experiencing kernel panics for some types of
 > > > traffic (ICMP and UDP). TCP seems not to be affected by this, at least
 > > > I have not been able to trigger the panic.
 > > > 
 > > > I have one tunnel (without an IP address) and use policy routing to
 > > > steer some traffic through the tunnels.  
 > > [...]  
 > > > An interesting thing is that I have seen different kernel panics being
 > > > triggered. The other one I have seen has RIP pointing to
 > > > e1000_xmit_frame() and the message "protocol 0800 is buggy". However,
 > > > the one I have posted is by far the most common.  
 > > I'm experiencing the same issue on two different machines. It happens on any 
 > > kernel starting from 3.10 when ip_tunnel/ip_tunnel_core were introduced.
 > >   
 > Can you please try the patch below?
 > I've posted the same patch already to netdev in the morning.
 > 
 > Subject: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in ip_tunnel_xmit  
 
Thank you very much. All works fine with that patch applied.
