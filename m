From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH v2 1/2] netfilter: ipvs: Verify that IP_VS protocol has
 been registered
Date: Sat, 14 Apr 2012 14:06:22 +0200
Message-ID: <CA+1xoqe0q=XH7mO6=qZKPxqZK8LU2Kk5BjmfLeQ9LUD1Ku65YA@mail.gmail.com>
References: <1334409722-26315-1-git-send-email-levinsasha928@gmail.com> <alpine.LFD.2.00.1204141439440.1680@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wensong@linux-vs.org, horms@verge.net.au, kaber@trash.net,
	davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1204141439440.1680@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 14, 2012 at 1:53 PM, Julian Anastasov <ja@ssi.bg> wrote:
> =A0 =A0 =A0 =A0Ops. It seems now we expose old problem when
> no protocol is configured. As this change probably will
> go to stable kernels, lets make it correct. Can you
> remove the defines around register_ip_vs_proto_netns, so
> that it is always compiled. One that wants to save
> memory will not disable all protocols. See commit
> 091bb34c143674d37a59b2d4857534f7106c5d7d for reference.

Oh, so it wasn't getting built right now at all if we didn't select
any protocols.

How about moving those defines down to our loop as well? this way
everything will behave exactly like it did before.
