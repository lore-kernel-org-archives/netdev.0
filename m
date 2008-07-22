From: Vince Busam <vbusam@google.com>
Subject: Re: [PATCHv2 0/2] IPVS: Add Generic Netlink configuration interface
Date: Tue, 22 Jul 2008 15:59:42 -0700
Message-ID: <4886665E.5060209@google.com>
References: <1216645375-20410-1-git-send-email-juliusv@google.com> <20080722003403.GC9041@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julius Volz <juliusv@google.com>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	tgraf@suug.ch
To: Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080722003403.GC9041@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman wrote:
> I'm not an expert on netlink, but these patches are looking good to me.
> Is the user-space portion available somewhere?

http://sixpak.org/vince/google/ipvsadm-1.25-nl-1.tar.gz

This version will fall back to the old sockopt interface if netlink 
fails, and is thus fully backward compatible with old kernels.  The 
interface for libipvs did change slightly to allow for IPv6 addresses, 
which only work through netlink, and will return error if tried on the 
old sockopt interface.

Vince
