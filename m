From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: fix skb_copy_expand offset calculation
Date: Thu, 6 Nov 2003 12:20:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031106122011.49d18674.davem@redhat.com>
References: <3FAA832A.6000505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FAA832A.6000505@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 06 Nov 2003 18:21:46 +0100
Patrick McHardy <kaber@trash.net> wrote:

> The patch is verified to fix the problem that led me to this, ipt_REJECT
> produced broken RSTs which triggered the "ipt_hook: happy cracking!"
> line in ip_conntrack_standalone.c.

Great work Patrick, your analysis and fix is definitely correct.

Patch applied, thanks.
