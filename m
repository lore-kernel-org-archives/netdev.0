From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (4/4) packet scheduler -- use get_jiffies_64
Date: Tue, 29 Jun 2004 14:46:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629144649.1d0b5723.davem@redhat.com>
References: <20040629140021.367695ff@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040629140021.367695ff@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Jun 2004 14:00:21 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The packet scheduler simulates 64 bit jiffies on 32 bit platforms by running
> a timer keeping a mark and and offset.  Since there is no locking and this is
> racy and doesn't handle jiffie wrap real well.
> 
> We can use get_jiffies_64 on 2.6 do get what is needed.
> The downside is the overhead of a function call, and a cache miss in get_jiffies_64.

Looks great, applied.
