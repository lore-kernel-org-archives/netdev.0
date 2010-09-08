From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Wed, 8 Sep 2010 21:12:14 +0200
Message-ID: <201009082112.14877.lindner_marek@yahoo.de>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<201009081142.31610.sven.eckelmann@gmx.de>
	<AANLkTimnBqkiO26wqEQOm+AgSJgQLtQmAe8R-kB6CqtZ@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <AANLkTimnBqkiO26wqEQOm+AgSJgQLtQmAe8R-kB6CqtZ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 September 2010 20:22:42 Jesse Gross wrote:
> Potentially one way to do this is to build on top of Open vSwitch.  It
> contains a pretty generic flow-based kernel module for forwarding data
> packets and making simple modifications.  Control packets can be sent
> to userspace to handle the routing logic, while data packets remain in
> the kernel for performance.  This would dramatically reduce the amount
> of code that needs to be in the kernel and may even help performance
> by simplifying the fast path.

Thanks for your input.

I had a quick look at the website to get an idea but I had to notice that 
there is quite a collection of daemons, kernel modules and apps. As you seem 
involved in this project, could you point us to the collection of tools that 
you think we would need to achieve the following:

* sending protocol traffic
* transmitting the routing logic
* encapsulation of the various packet types (see http://www.open-
mesh.org/browser/trunk/batman-adv/packet.h to get an idea)
* directly influence the traffic flow, i.e., ARQ for broadcasts, interface 
alternating, bonding, forward error correction, etc
* layer 2 fragmentation


Cheers,
Marek
