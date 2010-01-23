From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: linux bridge problem
Date: Sun, 24 Jan 2010 09:23:33 +1030
Message-ID: <20100124092333.230aa8eb@opy.nosense.org>
References: <549992e51001230641n2e40d2co31573386e258a5cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Metuki Sabhe <sabhe.metuki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:51515 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab0AWWxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 17:53:41 -0500
In-Reply-To: <549992e51001230641n2e40d2co31573386e258a5cb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Jan 2010 16:41:40 +0200
Metuki Sabhe <sabhe.metuki@gmail.com> wrote:

> CC'ing netdev too:
> 
> 
>  Hello,
> 
>  When I add interfaces to the bridge *after* I have "tcpdump -n -i br0"
>  running on the bridge,
>  my tcpdump don't see any communication. If I kill tcpdump and
>  re-execute it *after* I added
>  the interface to the bridge, it works just fine.
> 

How long are you waiting? Make sure you're not encountering the default
forwarding delay of 20 seconds You can change that value to zero using

brctl setfd br0 0

which brings new interfaces into forwarding state immediately, rather
than going through the listening and/or learning states.

>  The same behavior happens with my DHCP server (which listens only on
>  my bridge interface);
>  I need to re-execute (reset) it after I add the interface to the bridge.
> 
>  Is that normal ?
> 
>  Why does it happen ?
> 
>  What should I do ?
> 
>  It's a little awkward to reset my DHCP server every time I add a new
>  interface to the bridge..
> 
>  Thanks,
>  Sabhe
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
