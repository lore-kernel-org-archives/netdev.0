From: Patrick McHardy <kaber@trash.net>
Subject: Re: path: module replay
Date: Sun, 16 Jan 2005 20:50:08 +0100
Message-ID: <41EAC570.1010003@trash.net>
References: <1105900522.1090.798.camel@jzny.localdomain>	 <41EAB74F.6060507@trash.net>  <20050116185630.GZ26856@postel.suug.ch>	 <1105903033.1097.829.camel@jzny.localdomain> <1105903960.1097.836.camel@jzny.localdomain> <41EAC3EE.1020801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <41EAC3EE.1020801@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

> jamal wrote:
>
>> Ok, here is the last patch. I think module replay should be done from
>> that spot and to be consistent as well from cls_api.c for legacy stuff.
>> I also fixed a module ref count leak. the act_api piece is dependent 
>> on what i sent earlier for namsiz.
>> the cls_api change i believe conflicts with what Thomas sent yesterday.
>>
> We have to replay all orders since we dropped the rtnl. An action
> could have done __dev_get_by_* or something similar. Can you send
> a single patch for the module refcount leak please ?

I was wrong, the already initialized actions need to hold their own
references anyway. I'm going have another look and add your patch later
if I don't see other problems.

Regards
Patrick
