From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Must every packet have a creating socket? (was Re: Does a forwarded
 packet has a local socket with it?)
Date: Wed, 20 Apr 2005 18:20:04 -0700
Message-ID: <4266FFC4.6020305@hp.com>
References: <20050420172944.69275.qmail@web51501.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@redhat.com>, jamal <hadi@cyberus.ca>,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Park Lee <parklee_sel@yahoo.com>
In-Reply-To: <20050420172944.69275.qmail@web51501.mail.yahoo.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Can I think that every packet (e.g. IP packet) must
> have a corresponding creating socket? (i.e. Must every
> packet be created by a socket?) 

No.  ICMP messages come to mind - although I _suppose_ that since those are in 
response to other traffic, you could claim it was in response to something sent 
from a "socket" or "endpoint" - depends on how far away you consider it to still 
be  from a socket.

> Is there any other way to originate a packet?


> 
> Thank you.
> 
> Best Regards,
> Park Lee
> 
> 
> 		
> __________________________________ 
> Do you Yahoo!? 
> Make Yahoo! your home page 
> http://www.yahoo.com/r/hs

