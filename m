From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: Action repeat
Date: Sat, 30 Apr 2005 20:13:11 +0200
Message-ID: <4273CAB7.6080403@trash.net>
References: <1114879817.8929.117.camel@localhost.localdomain>	 <4273BB30.1050402@trash.net>  <4273BBAA.6060405@trash.net> <1114882045.8929.123.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114882045.8929.123.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Actions can set it. 
> Theres one in particular that i havent submitted yet that sets it
> amongst other items (depending on policy). We discussed this a while
> back when talking about ematches etc.

Since it only has such a short lifetime (action function sets it,
tcf_action_exec() clears it after changing classification result),
it would be less wasteful to just pass the classification result
to the actions. This would also avoid that skbs with tc_classid
already set can reach tcf_action_exec() (for example through mirred).

What do you think?

Regards
Patrick
