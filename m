From: Park Lee <parklee_sel@yahoo.com>
Subject: Must every packet have a creating socket? (was Re: Does a forwarded packet has a local socket with it?)
Date: Wed, 20 Apr 2005 10:29:43 -0700 (PDT)
Message-ID: <20050420172944.69275.qmail@web51501.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Neil Horman <nhorman@redhat.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Apr 2005 at 08:26, Neil Horman wrote:
> Not sure what your asking here.  Asking "Does these 
> two sockets belong to local socket?" is a pretty 
> meaningless question, as the terminology is 
> nonsensical. All sockets have a protocol associated 
> with them (except raw sockets, but thats another 
> topic).  When you create a socket you associate it 
> with a protocol family (AF_INET, AF_INET6, 
> AF_NETLINK, AF_APPLETALK, etc), 
> a connection type (SOCK_STREAM for connection 
> oriented  protocols, SOCK_DGRAM for connection-less 
> protocols), and a protocol (IPPROTO_TCP, 
> IPPROTO_UDP, etc).  Depending on the family, type 
> and protocol you select, you can talk to different 
> systems/services.
>
> Does that answer your question?

Thanks a lot.

Can I think that every packet (e.g. IP packet) must
have a corresponding creating socket? (i.e. Must every
packet be created by a socket?) 
Is there any other way to originate a packet?

Thank you.

Best Regards,
Park Lee


		
__________________________________ 
Do you Yahoo!? 
Make Yahoo! your home page 
http://www.yahoo.com/r/hs
