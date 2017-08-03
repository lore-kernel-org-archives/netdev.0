From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: policy: check policy direction value
Date: Thu, 3 Aug 2017 13:05:47 +0200
Message-ID: <20170803110547.GL2631@secunet.com>
References: <20170802175014.20582-1-vdronov@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>
To: Vladis Dronov <vdronov@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170802175014.20582-1-vdronov@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 02, 2017 at 07:50:14PM +0200, Vladis Dronov wrote:
> The 'dir' parameter in xfrm_migrate() is a user-controlled byte which is used
> as an array index. This can lead to an out-of-bound access, kernel lockup and
> DoS. Add a check for the 'dir' value.
> 
> This fixes CVE-2017-11600.
> 
> References: https://bugzilla.redhat.com/show_bug.cgi?id=1474928
> Fixes: 80c9abaabf42 ("[XFRM]: Extension for dynamic update of endpoint address(es)")
> Cc: <stable@vger.kernel.org> # v2.6.21-rc1
> Reported-by: "bo Zhang" <zhangbo5891001@gmail.com>
> Signed-off-by: Vladis Dronov <vdronov@redhat.com>

Applied to the ipsec tree, thanks!
