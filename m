From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: select() doesn't respect SO_RCVLOWAT ?
Date: Fri, 11 Mar 2005 19:09:41 +0000
Message-ID: <1110568180.17740.69.camel__5549.79468365691$1110807297$gmane$org@localhost.localdomain>
References: <Pine.LNX.4.61.0503101645190.29442@shang.nevis.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Resent-Message-Id: <20050314.223255.52292727.yoshfuji@wide.ad.jp>
To: Felix Matathias <felix@nevis.columbia.edu>
In-Reply-To: <Pine.LNX.4.61.0503101645190.29442@shang.nevis.columbia.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Iau, 2005-03-10 at 21:58, Felix Matathias wrote:
> Dear all,
> 
> I am running a 2.4.21-9.0.3.ELsmp #1 kernel and I can setsockopt and 
> getsockopt correctly the SO_RCVLOWAT option

The only value the code at least used to support was setting it to 1.
Are you sure you are actually setting/checking ok ?

