From: "David S. Miller" <davem@davemloft.net>
Subject: Re: HELP for dccp implementation.
Date: Wed, 1 Sep 2004 13:37:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901133709.3637d63d.davem@davemloft.net>
References: <412CC269.8080907@rus.uni-stuttgart.de>
	<1093454747.1034.85.camel@jzny.localdomain>
	<4135A32A.4030901@rus.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, dccp@ietf.org, netdev@oss.sgi.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: Zhikui Chen <zhikui.chen@rus.uni-stuttgart.de>
In-Reply-To: <4135A32A.4030901@rus.uni-stuttgart.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 01 Sep 2004 12:23:38 +0200
Zhikui Chen <zhikui.chen@rus.uni-stuttgart.de> wrote:

> If I assign a value such as 0x ee9fbc00 to sk in dccp_rcv (before lookup 
> calling), and comment lookkup calling, I get a error report from 
> bh_lock_sock(sk) calling inside dccp_rcv, which error report is  
> spin_is_locked on uninitialized spinlock ee9fbc00, and spin_lock 
> (<NULL>:ee9fbc00) already locked by <NULL>/73.
> 
> Do you know its reason? Thanks,

Zhikui, are you working together with Arnaldo using his
code base, like we suggested to you?  Or are you working
still on your own code?
