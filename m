From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Sat, 30 Apr 2005 13:27:25 -0400
Message-ID: <1114882045.8929.123.camel@localhost.localdomain>
References: <1114879817.8929.117.camel@localhost.localdomain>
	 <4273BB30.1050402@trash.net>  <4273BBAA.6060405@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4273BBAA.6060405@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-30-04 at 19:08 +0200, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > I have a question regarding tcf_action_init() and skb->tc_classid.
> > tcf_action_init() overrides the classification result with
> 
> That should be tcf_action_exec(), sorry.
> 

Actions can set it. 
Theres one in particular that i havent submitted yet that sets it
amongst other items (depending on policy). We discussed this a while
back when talking about ematches etc.

Unfortunately, classid is such a "hardcoded" concept in the qdiscs.

cheers,
jamal
