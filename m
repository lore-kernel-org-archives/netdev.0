From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ip_gre.c in 2.6.0-test5
Date: Thu, 25 Sep 2003 03:56:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925035606.5f1b780d.davem@redhat.com>
References: <3F715732.5060306@logix.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <michal@logix.cz>
In-Reply-To: <3F715732.5060306@logix.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Sep 2003 10:34:58 +0200
Michal Ludvig <michal@logix.cz> wrote:

> this trivial patch fixes possible kernel crash when using GRE tunnels in 
> 2.6.0-test. The problem was that "dev->init" wasn't set before 
> register_netdevice() call and so the initialization function was never 
> called. Consequently some fields in the tunnel structure were not 
> initialized what finally led to a kernel crash upon receiving the first 
> packet over the GRE tunnel.

Applied, thanks Michal.
