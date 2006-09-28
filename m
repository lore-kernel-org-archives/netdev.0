From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Re the default linux tcp algorithm being changed from bic to
 cubic.
Date: Thu, 28 Sep 2006 08:32:35 -0700
Message-ID: <20060928083235.77785a2c@freekitty>
References: <451B9ED6.9090208@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53423 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751328AbWI1QN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 12:13:29 -0400
To: Douglas Leith <doug.leith@nuim.ie>
In-Reply-To: <451B9ED6.9090208@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006 11:07:18 +0100
Douglas Leith <doug.leith@nuim.ie> wrote:

> Content-Type: text/plain; charset=UTF-8; format=flowed
> Content-Transfer-Encoding: 7bit
> 
> Steve,
> 
> I think we're all conscious of the fact that recent history contains 
> quite a number of proposals for changes to tcp's congestion control 
> algorithm for high bandwidth-delay product paths that on closer 
> inspection have proved problematic in one way or another.   It seems to 
> be a hard problem to solve, so maybe that's fair enough and hopefully 
> we'll end up with a workable solution soon.
> 
> Where I'm coming from here though is that bic was made the linux default 
> a year or so ago at a time when there were essentially no tests 
> available on its performance other than the infocom paper by Injong. 
> Subsequent tests have since highlighted a bunch of issues with bic.  To 
> my knowledge, we're currently in a similar situation with cubic as we 
> were with bic back then i.e. essentially no independent tests 
> investigating its behaviour.
> 
> Of course I know Injong has posted some test results, but these are 
> hardly independent as he's the author of both bic and cubic.  Have there 
> perhaps been private tests carried out (e.g. by osdl) ?  If so, would it 
> be possible to make them public ?  If not, well that would be good to 
> know too.
> 
> Doug
> 
> Hamilton Institute
> www.hamilton.ie

To get some exposure, how about moving the cubic patch off to -mm
kernel tree for one release, and leave BIC as the default for 2.6.19
