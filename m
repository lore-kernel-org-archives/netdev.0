From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Tue, 15 Feb 2005 23:27:48 +0100
Message-ID: <42127764.5050507@eurodev.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <20050212010504.X24171@build.pdx.osdl.net> <420E334B.8060805@eurodev.net> <420E77FA.6080007@eurodev.net> <20050215001334.GB27645@shell0.pdx.osdl.net> <42115E7E.6050909@eurodev.net> <20050215034708.GG27645@shell0.pdx.osdl.net> <4212757D.5070401@eurodev.net> <20050215222246.GI15867@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, jmorris@redhat.com,
        sds@epoch.ncsc.mil, serue@us.ibm.com
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050215222246.GI15867@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Wright wrote:

>* Pablo Neira (pablo@eurodev.net) wrote:
>  
>
>>I agree, maybe something like the example patch attached. Hope that helps.
>>    
>>
>
>This is better, but...
>
>  
>
>>-netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len))
>>+netlink_kernel_create(int unit, struct netlink_ops *nlops)
>>    
>>
>
>...this is exported interface, so would probably require a new function.
>  
>

I was aware of that. Actually I think that we can modify all calls to 
netlink_kernel_create (that aren't that much) to fit the new interface, 
I can post a patch to do that. I prefer providing just one function to 
create a netlink socket in kernel space.

--
Pablo
