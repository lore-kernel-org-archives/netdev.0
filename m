From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Why /sys/class/net/*/features is read-only?
Date: Mon, 23 May 2005 09:28:27 -0700
Message-ID: <20050523092827.7883af33@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.62.0505201346420.29305@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0505201346420.29305@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 May 2005 10:46:50 +0300 (EEST)
"Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro> wrote:

> Hello!
> 
> Why features file is read-only. If an admin want to force some attributes, 
> we can let them, right?
>

Leave it read-only because the hardware may not want to allow them on that flavor and so it would
have to be device specific.
