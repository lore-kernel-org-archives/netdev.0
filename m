From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Thu, 28 Oct 2004 16:35:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028163512.1e9d1629.davem@davemloft.net>
References: <41797696.9070905@candelatech.com>
	<20041022214611.GA4948@electric-eye.fr.zoreil.com>
	<41798506.1030909@candelatech.com>
	<417D675F.3000909@candelatech.com>
	<4181838B.6040002@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com, vlan@candelatech.com,
        romieu@fr.zoreil.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <4181838B.6040002@tpack.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 01:40:59 +0200
Tommy Christensen <tommy.christensen@tpack.net> wrote:

> Dave, I think this part of the patch should be reverted until someone comes up with a
> general scheme for flow_control handling through virtual devices.

It's certainly more correct, I think, than the code which
was there previously.

But in a way you're right, this is inconsistent with how IP and all
sorts of other tunnels behave, and if we change things we should
do it across the board.

So I will revert this part of his changes for now.

Thanks.
