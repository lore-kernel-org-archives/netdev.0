From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Re the default linux tcp algorithm being changed from bic to
 cubic.
Date: Thu, 28 Sep 2006 07:16:57 -0700
Message-ID: <20060928071657.5d0cbf70@freekitty>
References: <451B9ED6.9090208@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	Douglas Leith <doug.leith@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43152 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751185AbWI1O5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 10:57:55 -0400
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

My tests have been limited and showed no difference. It is worthy
of more discussion as to what is best. Could you rerun your tests?
