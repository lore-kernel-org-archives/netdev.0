From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CONFIG_XPS depends on L1_CACHE_BYTES being greater than
 sizeof(struct xps_map)
Date: Fri, 23 Oct 2015 13:03:08 -0700
Message-ID: <1445630588.22974.187.camel@edumazet-glaptop2.roam.corp.google.com>
References: <42430464-867C-4E0B-8E95-C6CDB6D8A0B2@bell.net>
	 <32A3BF6F-B243-4AD4-9AE9-A5F9DAE0270A@bell.net>
	 <B8E85737-5ECD-4CBE-8730-886B098C5FA4@bell.net>
	 <trinity-eda7d55d-7234-4b29-a15c-955f8ba0c95e-1445513884942@3capp-gmx-bs32>
	 <trinity-8980ad10-b889-45cf-8f37-a33ba9cf99ef-1445514797080@3capp-gmx-bs32>
	 <1445524549.2207.1.camel@HansenPartnership.com> <5628F868.3040105@bell.net>
	 <5629404B.8090805@gmx.de>
	 <1445550615.22974.128.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A8990.9000808@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	John David Anglin <dave.anglin@bell.net>
To: Helge Deller <deller@gmx.de>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <562A8990.9000808@gmx.de>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-10-23 at 21:25 +0200, Helge Deller wrote:

> Then, how about simply changing it to twice of L1_CACHE_BYTES ?
> 
> #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES * 2 - sizeof(struct xps_map)) / sizeof(u16))


Seems good to me.


