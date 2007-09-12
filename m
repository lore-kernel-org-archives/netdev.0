From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: update some distro-specific documentation
Date: Wed, 12 Sep 2007 15:40:04 -0400
Message-ID: <bdfc5d6e0709121240u2e8367cbx620d4d03194f1e85@mail.gmail.com>
References: <20070830212429.GA12676@gospo.rdu.redhat.com>
	 <21001.1189189669@death> <20070912181839.GD3754@gospo.rdu.redhat.com>
	 <1085.1189622856@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:10869 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035AbXILTkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 15:40:05 -0400
Received: by an-out-0708.google.com with SMTP id d31so44293and
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 12:40:04 -0700 (PDT)
In-Reply-To: <1085.1189622856@death>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/12/07, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
>
> >I could do that, or we could just take this as-is and get initscripts
> >fixed up to account for this.  Does that seem reasonable?
>
>         Changing initscripts is fine, too, but is there then going to be
> some (perhaps small) installed base for which the documentation will be
> incorrect?
>

Sure, but it could be wrong if we updated the kernel doc again after
initscripts was fixed and some chose not to update initscripts on
their boxes.  There could be a note about running a particular version
of initscripts, but I'd rather not start down the path of turning the
kernel doc into something that looks like distro release notes.

Either way it seems like there could be a chance for something to be
out of sync, so I guess we just have to pick the one that seems 'least
bad.'  I'd vote for whatever creates the fewest kernel patches. ;-)
