From: jamal <hadi@cyberus.ca>
Subject: Re: [NET]: Avoid useless iterating in netlink dump functions
Date: Sat, 07 May 2005 08:10:39 -0400
Message-ID: <1115467839.19561.14.camel@localhost.localdomain>
References: <427B8FC3.4000305@trash.net>
	 <1115413473.13922.38.camel@localhost.localdomain>
	 <427BDDD4.1000808@trash.net>
	 <1115414222.13922.41.camel@localhost.localdomain>
	 <427BE147.9080508@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427BE147.9080508@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-05 at 23:27 +0200, Patrick McHardy wrote:
> jamal wrote:
> > On Fri, 2005-06-05 at 23:12 +0200, Patrick McHardy wrote:
> > 
> >>action dumping is on my list for more treatment than this :)
> > 
> > Well, that does sound scary ;-> What do you have in mind.
> > Recall, there are two paths to dumping actions - unlike any other thing
> > in the kernel.
> 
> Don't worry :) Its actually action walking that is on my list.
> What I have planed is roughly:
> - clean up and move hashing functions to act_common.c
> - put data needed for hashing (size, pointer to memory, ...) in
>   struct tc_act_common, which is referenced by struct tc_action_ops
> - add callback based walking function so we don't need two of them
>
> This should also get rid of all the large functions contained in
> headerfiles.
> 

Ah, ok ;->
Weve discussed this already - I think DaveM already took in the simple
action patch that i posted a while back; it doesnt seem like you will
collide with that - just double check.

cheers,
jamal
