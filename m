From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Why is packet socket checked before bridge in netif_receive_skb?
Date: Tue, 26 Jul 2005 14:18:52 -0400
Message-ID: <20050726181850.GA9881@tuxdriver.com>
References: <C86180A8C204554D8A3323D8F6B0A29F6AF010@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Barber <simon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F6AF010@dhost002-46.dex002.intermedia.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2005 at 11:03:17AM -0700, Simon Barber wrote:

> The protocol handlers are also used to implement packet sockets. - Why
> is the all handler checked before the bridge hook?

Perhaps so that one can look at frames entering on a specific interface
rather than the bridge as a whole?

John
-- 
John W. Linville
linville@tuxdriver.com
