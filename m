From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number
 next.
Date: Tue, 26 Apr 2005 22:03:54 +0400
Message-ID: <20050426220354.5dd619bf@zanzibar.2ka.mipt.ru>
References: <20050411125932.GA19538@uganda.factory.vocord.ru>
	<d120d5000504260857cb5f99e@mail.gmail.com>
	<20050426202437.234e7d45@zanzibar.2ka.mipt.ru>
	<d120d50005042610317961a564@mail.gmail.com>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dmitry.torokhov@gmail.com, netdev@oss.sgi.com,
	Greg KH <greg@kroah.com>, Jamal Hadi Salim <hadi@cyberus.ca>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@redhat.com>,
	Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261569AbVDZSEv@vger.kernel.org>
To: dtor_core@ameritech.net
In-Reply-To: <d120d50005042610317961a564@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Apr 2005 12:31:58 -0500
Dmitry Torokhov <dmitry.torokhov@gmail.com> wrote:

> > There may not be the same work with different data.
> > 
> 
> Ugh, that really blows. Now every user of a particular message type
> has to coordinate efforts with other users of the same message type...
> 
> Imability to "fire and forget" undermines usefulness of whole
> connector. How will you for example implement hotplug notification
> over connector? Have kobject_hotplug wait and block other instances?
> But wait on what?

This is a simple load balancing schema.
Netlink messages may be dropped in socket queue when 
they are bing delivered to userspace - this is the same - 
if work queue can not be scheduled, message will be dropped,
but in this case userspace also can not be scheduled
and message will be dropped.
 
> -- 
> Dmitry
> 


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
