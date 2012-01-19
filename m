From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 4/5] SUNRPC: ip map cache per network namespace cleanup
Date: Thu, 19 Jan 2012 21:10:08 +0400
Message-ID: <4F184E70.5070902@parallels.com>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6> <20120119144931.9957.78601.stgit@localhost6.localdomain6> <20120119163722.GE527@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120119163722.GE527@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

19.01.2012 20:37, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Thu, Jan 19, 2012 at 06:49:31PM +0400, Stanislav Kinsbursky wrote:
>> This patch converts ip_map_cache per network namespace implemenetati=
on to the
>> same view, as other caches done in the series.
>> Besides generalization, code becomes shorter with this patch.
>
> Again, isnt' it ip_map_cache, and not one of the dynamically created
> cache details, that's being passed to the lookup routines?
>
> I may just be confused....
>

Nope. ip_map_cache was made per network namespace a long time ago.
But it was done in other way: no static templates - just allocation and=
=20
initialization.
But static template looks clearer to me. So I've used this approach for=
 other=20
caches. And decided to update ip_map_cache management in the same way.

--=20
Best regards,
Stanislav Kinsbursky
