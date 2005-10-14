From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [PATCH 01/14] Big kfree NULL check cleanup - net
Date: Fri, 14 Oct 2005 14:02:42 +0200
Message-ID: <9a8748490510140502p7675c037ie499440b35fabf31@mail.gmail.com>
References: <200510132125.44470.jesper.juhl@gmail.com>
	 <1129283450.5057.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	Ralf Baechle <ralf@linux-mips.org>,
	Greg Kroah-Hartman <greg@kroah.com>, dccp@vger.kernel.org,
	Patrick Caulfield <patrick@tykepenguin.com>,
	Jean Tourrilhes <jt@hpl.hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Andy Adamson <andros@umich.edu>,
	"J. Bruce Fields" <bfields@umich.edu>,
	Nenad Corbic <ncorbic@sangoma.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750725AbVJNMCp@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1129283450.5057.29.camel@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/14/05, Marcel Holtmann <marcel@holtmann.org> wrote:
> Hi Jesper,
>
> > This is the net/ part of the big kfree cleanup patch.
> >
> > Remove pointless checks for NULL prior to calling kfree() in net/.
> >
> >
> > Sorry about the long Cc: list, but I wanted to make sure I included everyone
> > who's code I've changed with this patch.
>
> you forgot me ;)
>

Sorry. I did try to include everyone, but there were so many different
areas and so many different persons that it was practically impossible
not to miss one or two people - surely was not intentional :)

[snip]
>
> Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
>
Thank you for that.

--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
