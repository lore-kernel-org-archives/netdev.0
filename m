From: greg chesson <greg@atheros.com>
Subject: Re: generic 802.11 stack
Date: Tue, 14 Sep 2004 17:51:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41479228.8080507@atheros.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <4145352F.4040807@pobox.com> <20040913162153.33ff37ec.davem@davemloft.net> <200409140819.25787.vkondra@mail.ru> <20040913223500.66c06cde.davem@davemloft.net> <20040914235512.GJ7839@ruslug.rutgers.edu> <414788A4.7070003@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        "David S. Miller" <davem@davemloft.net>,
        Vladimir Kondratiev <vkondra@mail.ru>, netdev@oss.sgi.com,
        acx100-devel@lists.sourceforge.net, hadi@cyberus.ca,
        jkmaline@cc.hut.fi, prism54-devel@prism54.org, sam@errno.com,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <414788A4.7070003@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Jeff Garzik wrote:
<snip>
> 
> 
> While I don't mind dual-licensing per se, I really dislike the 
> associated _technical_ crap that comes along with it, namely
> 
> * cross-OS compatibility wrappers
> * attempts to pretend that locking is _remotely_ similar between BSD and 
> Linux net stacks
> * use of non-Linux coding styles and memes
> * over-engineering and over-abstraction
> 

<snip>

I won't try to argue that these are not valid points -
except for maybe the last one because it is so subjective.
But not in this email.

I do argue that these points are not relevant to the question
of  whether or not a strict stack model of 802.11 management
and encapsulation procedures will suffice for anything more
than the most basic functionality.   That is an interesting question
that deserves an answer.

Personally, I think it will be necessary to have more shared information 
and procedures between
driver and 802.11 stack than is convenient or elegant in a strict stack 
arrangement.
  But, I've been wrong before.
Perhaps a fresh start with unbiased implementation will do something 
wonderful.
I look forward to seeing how a new implementation deals with the 
power-save packets
in the presence of qos, crypto, and fragmentation - all of which are 
necessary evils
if you want to pass wifi certification tests.

g
