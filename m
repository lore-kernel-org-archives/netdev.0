From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: Avoid useless iterating in netlink dump functions
Date: Fri, 06 May 2005 23:12:52 +0200
Message-ID: <427BDDD4.1000808@trash.net>
References: <427B8FC3.4000305@trash.net> <1115413473.13922.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1115413473.13922.38.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Looks good - you may also wanna treat tcf_dump_walker() and
> xfrm_dump_sa() the same way then. 
> 

action dumping is on my list for more treatment than this :)
xfrm_dump_sa()/xfrm_state_walk() could be changed to skip
smarter, but that is a different kind of change.

Regards
Patrick
