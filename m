From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC][2.4 PATCH] source address selection for ARP requests
Date: Wed, 20 Aug 2003 14:47:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820144711.13ea5f38.davem@redhat.com>
References: <1061320363.3744.14.camel@athena.fprintf.net>
	<Pine.LNX.3.96.1030820123600.14414I-100000@gatekeeper.tmr.com>
	<20030820100044.3127d612.davem@redhat.com>
	<3F43B389.5060602@candelatech.com>
	<20030820104831.6235f3b9.davem@redhat.com>
	<20030820213443.GA23939@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20030820213443.GA23939@alpha.home.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Aug 2003 23:34:43 +0200
Willy Tarreau <willy@w.ods.org> wrote:

> +	if (in_dev == NULL)
> +		return;

A NULL in_dev is what you'll see if no addresses are
assigned to the interface, therefore you must treat
this case similarly.
