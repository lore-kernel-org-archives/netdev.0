From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: change return values in mac_pton() function
Date: Wed, 13 Jul 2011 04:12:53 -0700 (PDT)
Message-ID: <20110713.041253.1879038886370324446.davem@davemloft.net>
References: <1310549424-5484-1-git-send-email-arend@broadcom.com>
	<CACVxJT-TXBd5S+HNfzNR2hnGUk2hMfTSQrkodUunUXOQ6+X8eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arend@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACVxJT-TXBd5S+HNfzNR2hnGUk2hMfTSQrkodUunUXOQ6+X8eg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 13 Jul 2011 13:09:03 +0300

> On Wed, Jul 13, 2011 at 12:30 PM, Arend van Spriel <arend@broadcom.com> wrote:
>> The original commit adding this function noted a diverge from usual
>> 0=success/-E=fail, but no motivation for it.
> 
> I thought it was obvious, but indeed wasn't explicitely
> mentioned in changelog. But see inet_pton(3).

Agreed it's better for mac_pton() to be consistent with existing,
similar, interfaces like inet_pton.
