From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1 net-next] net: dsa: replace count*size kmalloc by
 kmalloc_array
Date: Fri, 14 Nov 2014 20:32:29 +0100 (CET)
Message-ID: <47990659.56515.1415993549555.open-xchange@webmail.nmp.skynet.be>
References: <1415990202-28673-1-git-send-email-fabf@skynet.be> <1415990835.5912.20.camel@perches.com> <2104595537.56209.1415991758726.open-xchange@webmail.nmp.skynet.be> <1415992486.5912.23.camel@perches.com>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415992486.5912.23.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 14 November 2014 at 20:14 Joe Perches <joe@perches.com> wrote:
>
>
> On Fri, 2014-11-14 at 20:02 +0100, Fabian Frederick wrote:
> > On 14 November 2014 at 19:47 Joe Perches <joe@perches.com> wrote:
> > > On Fri, 2014-11-14 at 19:36 +0100, Fabian Frederick wrote:
> > > > kmalloc_array manages count*sizeof overflow.
> > >
> > > Fundamentally correct, but is this necessary or useful?
> > > sizeof(s8) isn't often going to be anything other than 1.
> > Absolutely, I thought it was a struct :)
> >
> > There must be a reason for so many cases though ...
>
> Some might be style symmetry for other sizeof(othertype)
> uses in the same paths, but most of them are just overkill
> or maybe lack of understanding.
>
> s8 is char so by definition it has to be 1.
>
> I doubt any of the code dates from PDP-8/TOPS-10 days.
>
>
95% comes from drivers tree. I guess one patch to Greg would be enough.
Are you interested in those patches or can I do them with some "Suggested-by" ?
