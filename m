From: Srivatsa Vaddagiri <vatsa@in.ibm.com>
Subject: Re: [RFC] Use RCU for tcp_ehash lookup
Date: Tue, 31 Aug 2004 18:34:02 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831130402.GB5534@in.ibm.com>
References: <20040831125941.GA5534@in.ibm.com>
Reply-To: vatsa@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        Dipankar <dipankar@in.ibm.com>, paulmck@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
In-Reply-To: <20040831125941.GA5534@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2004 at 06:29:41PM +0530, Srivatsa Vaddagiri wrote:
> I found _significant_ reduction in profile count (~56% savings)
> for __tcp_v4_lookup_established if it is made lock-free. 

I had made __tcp_v4_lookup_established to be a function call (rather
than an inline function) to gather readprofile statistics for the same.

-- 


Thanks and Regards,
Srivatsa Vaddagiri,
Linux Technology Center,
IBM Software Labs,
Bangalore, INDIA - 560017
