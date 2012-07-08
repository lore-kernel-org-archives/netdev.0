From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH next-next] ppp: change default for incoming protocol filter to NPMODE_DROP
Date: Sat, 7 Jul 2012 20:38:04 -0400
Message-ID: <20120708003804.GH19462@kvack.org>
References: <20120704013258.GA26225@kvack.org> <20120705.030027.655926012207641451.davem@davemloft.net> <20120706172800.GC19462@kvack.org> <20120707.161504.686059289738005570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120707.161504.686059289738005570.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 07, 2012 at 04:15:04PM -0700, David Miller wrote:
> From: Benjamin LaHaise <bcrl@kvack.org>
> Date: Fri, 6 Jul 2012 13:28:00 -0400
> 
> > How about the following addition instead to provide a list of
> > protocols to disable?
> 
> The userspace programs must accomodate all existing kernels, so
> the addition of this feature is rather pointless.

It's not existing kernels that this guards against, but the use of older 
versions of the API users on new kernels that support additional protocols.  
I'm in the middle of porting a PPP stack to using the ppp_generic interface, 
and there is no way for me to prevent packet types for protocols which are 
newly added to the kernel from getting these new packet types leaked.  I 
came across this exactly because I was testing this case.  I suppose I can 
ignore the issue, but I'd prefer to get it right since it is technically a 
security hole that bypasses PPP session authentication.

		-ben
-- 
"Thought is the essence of where you are now."
