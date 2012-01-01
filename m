From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix for nfacct infrastructure in net-next
Date: Sun, 01 Jan 2012 18:02:29 -0500 (EST)
Message-ID: <20120101.180229.1338519415596129407.davem@davemloft.net>
References: <1325434945-21900-1-git-send-email-pablo@netfilter.org>
	<20120101162358.GA21795@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120101162358.GA21795@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 1 Jan 2012 17:23:58 +0100

> On Sun, Jan 01, 2012 at 05:22:24PM +0100, pablo@netfilter.org wrote:
>> From: Pablo Neira Ayuso <pablo@netfilter.org>
>> 
>> Hi Dave,
>> 
>> Please, pull the following fix for the nfacct infrastructure already
>> in your net-next tree.
>> 
>> You can pull it from:
>> 
>> git://1984.lsi.us.es/net-net nf-next
>                        ^^^^^^^
> I meant to say net-next, of course.

I'm not pulling this.

If I pull from your "corrected" URL, "git://1984.lsi.us.es/net-next nf-next"
it starts to download 17937 objects.  Which means it's going to bring in all
of your -next work as well as my net-next tree upon which it is based, not
just this one bug fix.

These mistakes should never happen in the first place.

If you actually use "git request-pull" to generate the pull request
email body, you can NEVER get the URL wrong, GIT enforces it to be
correct and it enforces that the changes in your local tree are
present at the remote URL as well.

You can't make these kinds of errors and oversights when you want to
ask me to pull in bug fixes at the very last minute when Linus is
about to make a final release.

Just toss these fixes, if they are so important submit them to Greg KH
and the -stable branch after 3.2.0-final goes out.
