From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ibmtr - get rid of MOD_INC/DEC
Date: Thu, 14 Aug 2003 20:57:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030814205747.5fcd83d0.davem@redhat.com>
References: <20030813174658.2c5125af.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mikep@linuxtr.net, linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030813174658.2c5125af.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 13 Aug 2003 17:46:58 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> With the new module system MOD_INC/MOD_DEC are no longer necessary.
> Also changed to new module init/exit macros for function setup.
> 
> The module exit code can sleep, so calling schedule_timeout is better
> than spinning.

Can't we lose the MODULE ifdefs too?
