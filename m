From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch 3/18] gcc-3.5: ax25
Date: Sun, 25 Jan 2004 10:58:43 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040125.105843.15258420.davem@redhat.com>
References: <200401251106.i0PB6xo25047@mail.osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200401251106.i0PB6xo25047@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: akpm@osdl.org
   Date: Sun, 25 Jan 2004 03:06:59 -0800

   (Why is x25_alloc_socket() using GFP_ATOMIC?)

x25_dev.c:x25_receive_data() runs from softint, which
calls af_x25.c:x25_rx_call_request() which calls
af_x25.c:x25_make_new() which calls af_x25.c:x25_alloc_socket().
