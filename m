From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] bridge use read_lock when scanning device list
Date: Tue, 13 Jan 2004 16:19:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113161903.5eaf893a.davem@redhat.com>
References: <20040112134645.461f125e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040112134645.461f125e.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 12 Jan 2004 13:46:45 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> On 2.6.1, bridge is using rtnl_shlock which is equivalent to rtnl_lock when
> all it really needs to do is read_lock(&dev_base_lock).

Applied, thanks Stephen.
