From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Thu, 15 Jul 2010 13:48:57 -0700
Message-ID: <20100715134857.38d519c5@nehalam>
References: <4C3E0684.5060409@wildgooses.com>
	<4C3E1B54.40604@hp.com>
	<20100714203919.GD6682@nuttenaction>
	<20100714.145547.102555471.davem@davemloft.net>
	<20100714221301.GI6682@nuttenaction>
	<20100714234917.924f420d.billfink@mindspring.com>
	<AANLkTinbtGuMTPNyJqJtx_bqfQDPqbA1XqjhLe_pj1mX@mail.gmail.com>
	<4C3F66BA.8010002@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>,
	Bill Fink <billfink@mindspring.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, lists@wildgooses.com,
	davidsen@tmr.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C3F66BA.8010002@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Jul 2010 12:51:22 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> I have to wonder if the only heuristic one could employ for divining the initial 
> congestion window is to be either pessimistic/conservative or 
> optimistic/liberal.  Or for that matter the only one one really needs here?
> 
> That's what it comes down to doesn't it?  At any one point in time, we don't 
> *really* know the state of the network and whether it can handle the load we 
> might wish to put upon it.  We are always reacting to it. Up until now, it has 
> been felt necessary to be pessimistic/conservative at time of connection 
> establishment and not rely as much on the robustness of the "control" part of 
> avoidance and control.
> 
> Now, the folks at Google have lots of data to suggest we don't need to be so 
> pessimistic/conservative and so we have to decide if we are willing to be more 
> optimistic/liberal.  Broadly handwaving, the "netdev we" seems to be willing to 
> be more optimistic/liberal in at least a few cases, and the question comes down 
> to whether or not the "IETF we" will be similarly willing.

I am not convinced that a host being aggressive with initial cwnd (Linux) would
not end up unfairly monopolizing available bandwidth compared to older more conservative
implementations (Windows). Whether fairness is important or not is another debate.
