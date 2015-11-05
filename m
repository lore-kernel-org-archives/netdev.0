From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [patch -next] qlogic: qed: fix error codes in qed_resc_alloc()
Date: Thu, 5 Nov 2015 09:01:08 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E6BC48@avmb3.qlogic.org>
References: <20151105084128.GC19405@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	Dept-Eng Everest Linux L2 <everest-linux-l2@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20151105084128.GC19405@mwanda>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We accidentally return success instead of -ENOMEM here.
> 
> Fixes: fe56b9e6a8d9 ('qed: Add module with basic common support')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>

Thanks. Although you might also argue that it's good enough for this function
to always return -ENOMEM [given it's a resource allocation functions]
instead of bothering with setting 'rc' with correct error codes.

Regardless,
Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com
