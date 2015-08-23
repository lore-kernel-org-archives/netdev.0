From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 05/11] mlxsw: fix error return code
Date: Sun, 23 Aug 2015 20:52:26 +0200
Message-ID: <20150823185226.GA2396@nanopsycho.orion>
References: <1440288682-12732-1-git-send-email-Julia.Lawall@lip6.fr>
 <1440288682-12732-6-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, kernel-janitors@vger.kernel.org,
	Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440288682-12732-6-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sun, Aug 23, 2015 at 02:11:16AM CEST, Julia.Lawall@lip6.fr wrote:
>Return a negative error code on failure.
>
>A simplified version of the semantic match that finds this problem is as
>follows: (http://coccinelle.lip6.fr/)
>
>// <smpl>
>@@
>identifier ret; expression e1,e2;
>@@
>(
>if (\(ret < 0\|ret != 0\))
> { ... return ret; }
>|
>ret = 0
>)
>... when != ret = e1
>    when != &ret
>*if(...)
>{
>  ... when != ret = e2
>      when forall
> return ret;
>}
>// </smpl>
>
>Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Acked-by: Jiri Pirko <jiri@mellanox.com>
