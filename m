From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 12/18] IB/mlx5: Add kernel offload flow-tag
Date: Tue, 21 Jun 2016 18:41:34 +0300
Message-ID: <9dfdfcfd-3252-2c38-6c07-ae2d6eaa299a@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
 <1466174639-14576-13-git-send-email-saeedm@mellanox.com>
 <20160617160007.GA52082@ast-mbp.thefacebook.com>
 <CALzJLG-uoMKjZCC312JjfqnQaUW_-31eqeg0bQd+r3qp4Fa1ag@mail.gmail.com>
 <20160621021836.GA81638@ast-mbp.thefacebook.com>
 <CALzJLG8+xhJDO9FaGF+9OiBq1s1LD_cb3y-ybUkFD7DJG=SRaQ@mail.gmail.com>
 <CANn89iJbaOR5HpoaQLHoBGhariTACf-OLKRWqP3KBacvOUgGdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	"Maor Gottlieb" <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <edumazet@google.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0070.outbound.protection.outlook.com ([157.56.112.70]:5773
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750731AbcFUP5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 11:57:49 -0400
In-Reply-To: <CANn89iJbaOR5HpoaQLHoBGhariTACf-OLKRWqP3KBacvOUgGdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/2016 6:18 PM, Eric Dumazet wrote:
> One solution would be to setup a special netdev used only for sniffers
> (No IP address on it)
>
> -> Only changes would happen in the driver, to set skb->dev to this
> 'debug' device.

Eric,

Yep, that was an option too, but when we realized that libpcap has the 
means to add plug-in for non-netdevices (e.g usb, can devices and now we 
are thinking to add one for uverbs),  it means we can avoid adding tons 
of pretty complex code into the kernel driver and happily have simpler 
code is user-space, so... why not? will try that 1st.

Or.
