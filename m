From: "Alexander V. Lukyanov" <lav@netis.ru>
Subject: Re: 2.6.0-test9: access beyond end of device
Date: Thu, 30 Oct 2003 14:02:59 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031030110258.GA13681@night.netis.priv>
References: <20031029101240.GA12958@night.netis.priv> <20031029124003.4510bb1d.akpm@osdl.org> <20031030092248.GA7649@swing.yars.free.net> <20031030013904.6acaefe3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031030013904.6acaefe3.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 30, 2003 at 01:39:04AM -0800, Andrew Morton wrote:
> Congratulations, you broke the 2.6 networking code!

Probably not. I have found a problem in ip_wccp module which I have loaded.
It used ip_rcv while netif_rx is the proper function to use.

After I have fixed that, linux-2.6.0-test9 works well. Sorry for confusion.
I'll report if I find other problems. Thanks!

-- 
   Alexander.
