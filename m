From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: ethernet QoS support?
Date: Mon, 12 Jul 2004 18:08:52 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089621532.3063.8.camel@andromache>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
	 <200407092126.43021.vkondra@mail.ru> <200407091534.53166.sam@errno.com>
	 <200407101158.58089.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Sam Leffler <sam@errno.com>, hadi@cyberus.ca,
        Jeff Garzik <jgarzik@pobox.com>, Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200407101158.58089.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-07-10 at 18:28, Vladimir Kondratiev wrote:

> I continue to insist that for true MAC layer QoS, we need several Tx queues.

If you have several MAC-layer queues, then do you have
another set of MAC-layer scheduling?  If so, how do you
select the algorithm?

I suggest this can of worms requires further thought
before we end up with two layers of QoS queuing and
scheduling.

Cheers,
Glen

PS: Can we *please* deprecate use of the ToS bits. We had
    almost killed them and Linux is again encouraging their
    use, much to the despair of network operators (who want
    DiffServ, or at least DiffServ-compatible use of IP
    Precedence)

-- 
Glen Turner                           Tel: +61 8 8303 3936
Australian Academic & Research Network   www.aarnet.edu.au
