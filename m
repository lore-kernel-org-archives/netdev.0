From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tun - don't obscure error return from misc_register
Date: Mon, 15 Mar 2004 12:42:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315124201.4d48ab36.davem@redhat.com>
References: <20040315102539.0953af7e@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, vtun@office.satix.net.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040315102539.0953af7e@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Mar 2004 10:25:39 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> When Tun initialization fails it shouldn't obscure the error return, 
> There are several reasons it could fail, and when diagnosing user problems
> the error code might provide more info.

Applied, thanks Stephen.
