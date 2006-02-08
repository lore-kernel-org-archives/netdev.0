From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Wed, 08 Feb 2006 15:00:24 -0800
Message-ID: <43EA7808.6060105@hp.com>
References: <E1F6xei-0006hc-00@gondolin.me.apana.org.au>	<OF71FA79DA.C4F20DA5-ON8825710F.007B701A-8825710F.007CB97E@us.ibm.com> <20060208.144712.66821895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20060208.144712.66821895.davem@davemloft.net>
To: unlisted-recipients:; (no To-header on input)
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: David Stevens <dlstevens@us.ibm.com>
> Date: Wed, 8 Feb 2006 14:45:08 -0800
> 
> 
>>        Why would sparse complain about this? 0 is a well-defined
>>pointer value (the only value guaranteed to be by the language).
> 
> 
> Because sparse goes beyond the standards and tries to
> catch cases that usually end up being bugs.

So, how might it tell when someone is mistakenly using a pointer as a boolean if 
it takes a pass on if(foo) or if(!foo)  instead of looking for if(foo == NULL) 
or if(foo != NULL)?    (or I suppose if (NULL == foo) and if (NULL != foo))

it would seem that the compars with NULL, when read by pseudorandom folks would 
be more likely to reinforce that foo is a pointer rather than a boolean/flag.

rick jones
