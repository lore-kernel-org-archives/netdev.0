From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (3/3) netem: adjust parent qlen when duplicating
Date: Tue, 03 May 2005 22:01:48 -0700
Message-ID: <4278573C.3040503@osdl.org>
References: <20050503162550.30acf31a@dxpl.pdx.osdl.net>	<42780AC1.8040409@trash.net>	<20050503163025.38bb9682.davem@davemloft.net>	<42780DB2.2090201@trash.net> <20050503165937.0c6cac6d.davem@davemloft.net> <42782B59.3000500@trash.net> <42782BEE.2050206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42782BEE.2050206@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I like Patrick's solution; and eventually I'll remove duplicate from 
netem and use mirred action. The problem is that it makes setting up a 
test environment even more complicated (and error prone). The interface 
to this is just getting so messy (sorry Jamal), with mirred, filters 
etc..  Unfortunately, tcng doesn't seem to be getting updated regularly.
