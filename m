From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] gc_min_interval in milleseconds via /proc
Date: Wed, 26 Jan 2005 15:38:54 -0800
Message-ID: <20050126153854.3351b203.davem@davemloft.net>
References: <16887.46410.873506.298630@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16887.46410.873506.298630@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 26 Jan 2005 16:20:42 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> The second resolution is very inconvenient. Milleseconds would be nicer.

It would, but since this is a user visible API we really can't
change it.

We could instead make another sysctl (perhaps name it something
like "gc_min_interval_ms") to do what you propose, and then
we'd keep the existing one around for compatibility.
