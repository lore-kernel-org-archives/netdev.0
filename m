From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] add likely/unlikely to pskb_may_pull
Date: Wed, 30 Jul 2003 16:53:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730165319.4354d484.davem@redhat.com>
References: <20030730161854.3cb03258.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030730161854.3cb03258.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jul 2003 16:18:54 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Code that deals with received headers needs to be robust and use pskb_may_pull in many
> places, but except in the case of DOS attacks, the packets are always correctly formed
> so optimize for that case.

Applied, thanks Stephen.
