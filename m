From: Andi Kleen <ak@suse.de>
Subject: Re: Paper on lookup in Linux.
Date: Mon, 4 Sep 2006 15:29:39 +0200
Message-ID: <200609041529.39688.ak@suse.de>
References: <17660.4445.36266.884445@robur.slu.se> <200609041424.26564.ak@suse.de> <17660.8632.602340.514616@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, snilsson@nada.kth.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:14057 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751375AbWIDN3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 09:29:45 -0400
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17660.8632.602340.514616@robur.slu.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 04 September 2006 14:53, Robert Olsson wrote:

>  No we haven't put struct socket in the leafs (result node) yet we just kept 
>  dst entries and some stateful flow variables that we used for active GC 
>  and flow logging so far. So 128 bit flow version of the dst hash. It would 
>  have taken a lot a of more work and we wanted to get this paper out. Also 
>  ip_route_input is not the place have the lookup if we with unified include 
>  ip6. So we focused on designing and building the lookup core.

Thanks.

The reason I'm asking is that we still have trouble with the TCP hash tables
taking far too much memory, and your new data structure might provide a nice 
alternative. 

-Andi
