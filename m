From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: generic 802.11 stack
Date: Tue, 14 Sep 2004 20:11:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414788A4.7070003@pobox.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <4145352F.4040807@pobox.com> <20040913162153.33ff37ec.davem@davemloft.net> <200409140819.25787.vkondra@mail.ru> <20040913223500.66c06cde.davem@davemloft.net> <20040914235512.GJ7839@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Vladimir Kondratiev <vkondra@mail.ru>, greg@atheros.com,
        netdev@oss.sgi.com, acx100-devel@lists.sourceforge.net,
        hadi@cyberus.ca, jkmaline@cc.hut.fi, prism54-devel@prism54.org,
        sam@errno.com, vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040914235512.GJ7839@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> On Mon, Sep 13, 2004 at 10:35:00PM -0700, David S. Miller wrote:
> 
>>On Tue, 14 Sep 2004 08:14:56 +0300
>>Vladimir Kondratiev <vkondra@mail.ru> wrote:
>>
>>
>>>Fine. Let it be this way. It may take for me some time till I can sumbit 
>>>something, I want that it will kind of work with minimum functionality.
>>
>>Ok, good luck Vladimir :-)
> 
> 
> Vladimir,
> 
> How about dual-licensing this work as GPL/BSD? I believe the BSD teams might
> benefit from this work.


While I don't mind dual-licensing per se, I really dislike the 
associated _technical_ crap that comes along with it, namely

* cross-OS compatibility wrappers
* attempts to pretend that locking is _remotely_ similar between BSD and 
Linux net stacks
* use of non-Linux coding styles and memes
* over-engineering and over-abstraction


Linus Credo #788 is "do what you must, and no more."

If Vladimir is working from DaveM's code template, then he is working at 
the lowest, most native _Linux kernel_ levels to interface with the net 
stack.

I'm all for code sharing -- but I'm all for rationality too.  There will 
_inevitably_ be _fundamental_ differences between BSD and Linux net 
stacks, and to attempt to code for both OS's will be nasty and time 
consuming, IMHO.

	Jeff
