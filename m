From: "David S. Miller" <davem@redhat.com>
Subject: Re: net/packet/af_packet.c:{1057,1073}: flags vs. msg->flags
Date: Mon, 10 Nov 2003 23:12:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110231238.4742a158.davem@redhat.com>
References: <3FAF7236.7020209@softhome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ihar 'Philips' Filipau" <filia@softhome.net>
In-Reply-To: <3FAF7236.7020209@softhome.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 10 Nov 2003 12:10:46 +0100
"Ihar 'Philips' Filipau" <filia@softhome.net> wrote:

>     On line 1057 we have: "msg->msg_flags|=MSG_TRUNC;" to indicate that 
> message was truncated.
> 
>     But on line 1073, where we make return status to user, we check 
> against user suplied flags, but NOT msg->msg_flags.
> 
>     It looks like obvious typo.

Indeed, you're right.

Thanks for the report, I'll fix this in both 2.4.x and 2.6.x
