From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net/: (netfilter related) Remove unnecessary
 returns from void function()s
Date: Thu, 13 May 2010 08:52:24 -0700
Message-ID: <1273765944.21514.35.camel@Joe-Laptop.home>
References: <1273600346.20514.247.camel@Joe-Laptop.home>
	 <4BEBFC84.5020707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BEBFC84.5020707@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-05-13 at 15:20 +0200, Patrick McHardy wrote:
> Joe Perches wrote:
> > This patch removes from net/ netfilter files
> > all the unnecessary return; statements that precede the
> > last closing brace of void functions.
> > Done via:
> > $ grep -rP --include=*.[ch] -l "return;\n}" net/ | \
> >   xargs perl -i -e 'local $/ ; while (<>) { s/\n[ \t\n]+return;\n}/\n}/g; print; }'
> > 
> Applied, but I changed the patch to keep the two return statements
> below in otherwise empty function bodies since I consider that more
> aesthetically pleasing.

No worries, thanks.
The patch is just for taste and consistency.


