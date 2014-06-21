From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] net/dsa/dsa.c: remove null test before kfree
Date: Sat, 21 Jun 2014 10:37:24 +0200
Message-ID: <b991e868-c253-4b1a-8c95-56106c36d512@email.android.com>
References: <1403296607-6065-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403296607-6065-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 20 June 2014 22:36:47 CEST, Fabian Frederick <fabf@skynet.be> wrote:
>Fix checkpatch warning:
>WARNING: kfree(NULL) is safe this check is probably not required

"probably not" implies that there are cases where the check *is* requir=
ed.  That means that your commit message should explain why this partic=
ular check is redundant.

I haven't analyzed your changes here, so they could be fine for all I k=
now. My point is that such analysis is your job when submitting cleanup=
s like this one.



Bj=C3=B8rn
