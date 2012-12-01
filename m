From: Anders Kaseorg <andersk@MIT.EDU>
Subject: Re: Wireless regression in workqueue: use mod_delayed_work() instead
 of __cancel + queue
Date: Sat, 1 Dec 2012 18:53:07 -0500 (EST)
Message-ID: <alpine.DEB.2.00.1212011852100.25064@dr-wily.mit.edu>
References: <alpine.DEB.2.00.1211280953350.26602@dr-wily.mit.edu> <alpine.DEB.2.00.1211281016320.26602@dr-wily.mit.edu> <20121130211435.GJ3873@htj.dyndns.org> <20121130225619.GD6021@htj.dyndns.org> <alpine.DEB.2.00.1211302234410.25064@dr-wily.mit.edu>
 <20121201143926.GB2685@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121201143926.GB2685@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 1 Dec 2012, Tejun Heo wrote:
> Can you please test this one too?  Thanks!
>=20
> [=E2=80=A6]
> +	if (!delay) {
> +		__queue_work(cpu, wq, &dwork->work);
> +		return;
> +	}
> +
> [=E2=80=A6]
> -	if (!delay)
> -		return queue_work_on(cpu, wq, &dwork->work);
> -

Yes, this one fixes the bug too (on v3.7.0-rc7).

Anders
