From: "David S. Miller" <davem@redhat.com>
Subject: Re: comment about struct tcp_tw_bucket in struct sock
Date: Wed, 14 May 2003 12:17:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514.121727.74733052.davem@redhat.com>
References: <20030513210541.GA4415@suse.de>
	<20030513.163150.28800008.davem@redhat.com>
	<20030514080043.GA2575@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: olh@suse.de
In-Reply-To: <20030514080043.GA2575@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Olaf Hering <olh@suse.de>
   Date: Wed, 14 May 2003 10:00:43 +0200

    On Tue, May 13, David S. Miller wrote:
   
   > It's documented in tcp.h already.
   
   True, but not in struct sock.

When you edit the layout of struct sock you assume
the full responsibility that you might be breaking
something that uses struct sock.  This includes
third party modules.

You shouldn't be making changing to it lightly.  How this made TCP
blow up is the negative feedback you get for trying to change struct
sock ;-)
