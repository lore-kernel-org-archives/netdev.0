From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch 2.4] kernel oops on VLAN removal
Date: Tue, 19 Aug 2003 12:41:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819124154.75ec0383.davem@redhat.com>
References: <3F424405.6020002@mrv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eran Mann <emann@mrv.com>
In-Reply-To: <3F424405.6020002@mrv.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 18:36:37 +0300
Eran Mann <emann@mrv.com> wrote:

> The current code attempts to add a proc entry for each vlan device,
> however there is no check whether this attempt succeeded. When a device
> is unregistered it tries to remove the proc entry, if none was added
> the oops follows...

Patch applied to my 2.4.x tree, scheduled for 2.4.23-preX

Can someone check out 2.6.x?
