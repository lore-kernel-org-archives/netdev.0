From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: linux-next: manual merge of the arm-soc tree with the net-next
 tree
Date: Tue, 18 Jun 2013 18:36:39 +0400
Message-ID: <51C07077.3040600@cogentembedded.com>
References: <20130617163920.04523ba6de50bcc81563f33e@canb.auug.org.au> <51BF1461.8060401@cogentembedded.com> <CABYn4sx3PYBVMyio8uo-KhwprQnCmt_5k2EMaa9_EW2ud2q2nQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, linux-next@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Simon Horman <horms+renesas@verge.net.au>
To: Bastian Hecht <hechtb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABYn4sx3PYBVMyio8uo-KhwprQnCmt_5k2EMaa9_EW2ud2q2nQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 18-06-2013 12:33, Bastian Hecht wrote:

> Sergei is completely right I think. He was sceptic about the commit in
> a mail some days ago already. Unfortunately I recently haven't had
> access to my development environment to check what's up with this
> patch. I'm sorry that it ended up to you both to deal with it. I have
> written some simple bindings for the sh-eth and wanted to use it for
> our DT reference version for the Armadillo board but discarded it as I
> saw Nobuhiro Iwamatsu, the author of the sh-eth driver, cooked up some
> more mature version. I don't see them in the next branch of Simon, so
> until they appear there we can delete commit 9e0b428f079d ("ARM:

    It won't appear there. I'll just NAK it, I think I've alredy told 
Iwamatsu-san that the full blown device tree binding for this driver is 
no-go. The best we can do is use OF_DEV_AUXDATA() to rename the DT 
sourced platform device to a traditional one and assign to it the 
platform data.

> shmobile: r8a7740: Add interim sh-eth device name to clocks list")

    Unfortunately, it's now too late to just delete it at this point. I 
missed the patch unfortunately when it was just submitted.

> that is only needed for sh-eth DT usage.

> Thanks,

>   Bastian

WBR, Sergei
