From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] New kernel function to get IP overhead
 on a socket.
Date: Mon, 3 Apr 2017 19:12:20 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1704031906060.6985@vera100.eng.brocade.com>
References: <alpine.DEB.2.11.1703231809410.19388@vera100.eng.brocade.com> <14517769-bf88-a541-4948-1504a6d7acac@katalix.com> <alpine.DEB.2.11.1704031316390.24947@vera100.eng.brocade.com> <20170403.133040.2079781719239791612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: parameswaran.r7@gmail.com, jchapman@katalix.com, kleptog@svana.org,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36416 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdDDCMV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 22:12:21 -0400
In-Reply-To: <20170403.133040.2079781719239791612.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi Dave,

Please see inline:

On Mon, 3 Apr 2017, David Miller wrote:

> From: "R. Parameswaran" <parameswaran.r7@gmail.com>
> Date: Mon, 3 Apr 2017 13:28:11 -0700 (PDT)
> 
> > Can I take this to mean that we do need to factor in IP options in 
> > the L2TP device MTU setup (i.e approach in the posted patch is okay)? 
> > 
> > If yes, please let me know if I can keep the socket IP option overhead 
> > calculations in a generic function, or it would be better to move it back into 
> > L2TP code? 
> 
> If the user creates and maintains this UDP socket, then yes we have to
> account for potential IP options.
> 

Can I take this to mean that the patch in its present form is 
acceptable (patch currently accounts for IP options on the socket)? 
Please let me know if any further change is needed (I'll clean up the 
krobot reported errors after this).

thanks,

Ramkumar
