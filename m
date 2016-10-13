From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH net-next 00/11] net: Fix netdev adjacency tracking
Date: Thu, 13 Oct 2016 08:32:40 -0600
Message-ID: <eedea44e-24de-e6f7-c42f-a13461d16d6a@cumulusnetworks.com>
References: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
 <20161013073424.GB1816@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161013073424.GB1816-6KJVSR23iU488b5SBfVpbw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/13/16 1:34 AM, Jiri Pirko wrote:
> 
> Although I didn't like the "all-list" idea when Veaceslav pushed it
> because it looked to me like a big hammer, it turned out to be very handy
> and quick for traversing neighbours. Why it cannot be fixed?
> 
> The walks with possibly hundreds of function calls instead of a single
> list traverse worries me.
> 

I have been looking at this code for a week now. Every solution I came up with that solved the original problems introduced new ones -- usually with adjacency remove expecting an adjacency that did not exist. In the end I came to the conclusion it is not possible to maintain an all_adj_list when the upper tree can have multiple paths to the top device. If someone thinks otherwise I am happy to test a patch.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
