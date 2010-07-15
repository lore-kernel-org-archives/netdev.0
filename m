From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Thu, 15 Jul 2010 12:51:22 -0700
Message-ID: <4C3F66BA.8010002@hp.com>
References: <4C3E0684.5060409@wildgooses.com> <4C3E1B54.40604@hp.com>	<20100714203919.GD6682@nuttenaction>	<20100714.145547.102555471.davem@davemloft.net>	<20100714221301.GI6682@nuttenaction>	<20100714234917.924f420d.billfink@mindspring.com> <AANLkTinbtGuMTPNyJqJtx_bqfQDPqbA1XqjhLe_pj1mX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, lists@wildgooses.com,
	davidsen@tmr.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:37848 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934564Ab0GOTv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 15:51:26 -0400
In-Reply-To: <AANLkTinbtGuMTPNyJqJtx_bqfQDPqbA1XqjhLe_pj1mX@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have to wonder if the only heuristic one could employ for divining the initial 
congestion window is to be either pessimistic/conservative or 
optimistic/liberal.  Or for that matter the only one one really needs here?

That's what it comes down to doesn't it?  At any one point in time, we don't 
*really* know the state of the network and whether it can handle the load we 
might wish to put upon it.  We are always reacting to it. Up until now, it has 
been felt necessary to be pessimistic/conservative at time of connection 
establishment and not rely as much on the robustness of the "control" part of 
avoidance and control.

Now, the folks at Google have lots of data to suggest we don't need to be so 
pessimistic/conservative and so we have to decide if we are willing to be more 
optimistic/liberal.  Broadly handwaving, the "netdev we" seems to be willing to 
be more optimistic/liberal in at least a few cases, and the question comes down 
to whether or not the "IETF we" will be similarly willing.

rick jones
