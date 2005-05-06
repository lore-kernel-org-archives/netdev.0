From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: Avoid useless iterating in netlink dump functions
Date: Fri, 06 May 2005 23:27:35 +0200
Message-ID: <427BE147.9080508@trash.net>
References: <427B8FC3.4000305@trash.net>	 <1115413473.13922.38.camel@localhost.localdomain>	 <427BDDD4.1000808@trash.net> <1115414222.13922.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1115414222.13922.41.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2005-06-05 at 23:12 +0200, Patrick McHardy wrote:
> 
>>action dumping is on my list for more treatment than this :)
> 
> Well, that does sound scary ;-> What do you have in mind.
> Recall, there are two paths to dumping actions - unlike any other thing
> in the kernel.

Don't worry :) Its actually action walking that is on my list.
What I have planed is roughly:
- clean up and move hashing functions to act_common.c
- put data needed for hashing (size, pointer to memory, ...) in
  struct tc_act_common, which is referenced by struct tc_action_ops
- add callback based walking function so we don't need two of them

This should also get rid of all the large functions contained in
headerfiles.

Regards
Patrick
