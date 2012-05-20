From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6/exthdrs: strict Pad1 and PadN check
Date: Sun, 20 May 2012 16:59:52 -0400 (EDT)
Message-ID: <20120520.165952.949615878777060190.davem@davemloft.net>
References: <1337515173-23648-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337515173-23648-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Sun, 20 May 2012 13:59:33 +0200

> The following tightens the padding check from commit
> c1412fce7eccae62b4de22494f6ab3ff8a90c0c6 :
> 
> * Take into account combinations of consecutive Pad1 and PadN.
> 
> * Catch the corner case of when only padding is present in the
>   header, when the extention header length is 0 (i.e., 8 bytes).
>   In this case, the header would have exactly 6 bytes of padding:
> 
> +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> :  Next Header  : Hdr Ext Len=0 :                               :
> +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               +
> :                        Padding (Pad1 or PadN)                 :
> +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

Applied to net-next, thanks a lot.
