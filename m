From: jamal <hadi@cyberus.ca>
Subject: Re: ethernet QoS support?
Date: 12 Jul 2004 08:26:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089635216.1054.271.camel@jzny.localdomain>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
	 <200407092126.43021.vkondra@mail.ru> <200407091534.53166.sam@errno.com>
	 <200407101158.58089.vkondra@mail.ru>  <1089621532.3063.8.camel@andromache>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Vladimir Kondratiev <vkondra@mail.ru>, netdev@oss.sgi.com,
        Sam Leffler <sam@errno.com>, Jeff Garzik <jgarzik@pobox.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Glen Turner <glen.turner@aarnet.edu.au>
In-Reply-To: <1089621532.3063.8.camel@andromache>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-07-12 at 04:38, Glen Turner wrote:
> On Sat, 2004-07-10 at 18:28, Vladimir Kondratiev wrote:
> 
> > I continue to insist that for true MAC layer QoS, we need several Tx queues.
> 
> If you have several MAC-layer queues, then do you have
> another set of MAC-layer scheduling?  If so, how do you
> select the algorithm?

A mapping is being suggested. Qdiscs handle the queueing. Send it to
the driver/MAC layer with instructions of which queue it goes on.

> I suggest this can of worms requires further thought
> before we end up with two layers of QoS queuing and
> scheduling.

Refer to the thread earlier; i think the mapping is pretty much
sufficient.

> PS: Can we *please* deprecate use of the ToS bits. We had
>     almost killed them and Linux is again encouraging their
>     use, much to the despair of network operators (who want
>     DiffServ, or at least DiffServ-compatible use of IP
>     Precedence)

I know you are refering to the default linux behavior, but
do you use any of the diffserv enablers like dsmark to set DSCPs?
I think 2.6.7+ we should change that default behavior. What exactly
are the network operators complaining about?

cheers,
jamal
