From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] deinline sock_i_uid,sock_i_ino
Date: Wed, 7 Jul 2004 14:06:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707140653.513fbe84.davem@redhat.com>
References: <20040707095443.7b54b63d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040707095443.7b54b63d@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 7 Jul 2004 09:54:43 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The sock_i_uid and sock_i_ino functions are only called by /proc type
> interfaces, so they don't need to be inlined. 
> 
> Also, the inline functions writeable, rcvtimeo, sndtimeo are test for
> value functions that don't change their argument.

Looks good, applied.
