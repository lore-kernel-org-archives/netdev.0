From: jamal <hadi@cyberus.ca>
Subject: Re: tun device - bug or feature? WAS(Re: IMQ / new Dummy device
	post.
Date: 26 Apr 2004 22:22:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1083032546.1039.271.camel@jzny.localdomain>
References: <wazza.87ad18jbdl.fsf@message.id>
	 <1082427350.1034.70.camel@jzny.localdomain>
	 <wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
	 <wazza.87hdvddqxq.fsf@message.id>
	 <1082639764.1059.81.camel@jzny.localdomain>
	 <87oepjx65r.87n053x65r@87llknx65r.message.id>
	 <1082719745.1057.27.camel@jzny.localdomain>
	 <1082816083.1054.32.camel@jzny.localdomain>
	 <1083007898.7788.276.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, syrius.ml@no-log.org, Jeff Garzik <jgarzik@pobox.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Max Krasnyansky <maxk@qualcomm.com>
In-Reply-To: <1083007898.7788.276.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-04-26 at 15:31, Max Krasnyansky wrote:

> Well TUN does not have any hw headers so there is nothing to pull :).

didnt notice the dev->hard_header_len being 0 before ;->
In that case it makes sense to have nothing to pull.
Theres about 5 devices like that.
I need to rethink a little on behavior of mirred with devices that have
no hardware headers. I may speacial case them.

cheers,
jamal
