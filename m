From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 6/10] ixgbe: Use ARRAY_SIZE macro
Date: Tue, 05 Sep 2017 13:01:18 -0700
Message-ID: <1504641678.28899.12.camel@perches.com>
References: <1504439110050-939061377-0-diffsplit-thomas@m3y3r.de>
         <1504439110050-1907815276-6-diffsplit-thomas@m3y3r.de>
         <20170905.115044.551456011251065741.davem@davemloft.net>
         <20170905194419.pdwrkqdad6tbq7hs@olymp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Meyer <thomas@m3y3r.de>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170905194419.pdwrkqdad6tbq7hs@olymp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-09-05 at 21:45 +0200, Thomas Meyer wrote:
> On Tue, Sep 05, 2017 at 11:50:44AM -0700, David Miller wrote:
> > From: Thomas Meyer <thomas@m3y3r.de>
> > Date: Sun, 03 Sep 2017 14:19:31 +0200
> > 
> > > Use ARRAY_SIZE macro, rather than explicitly coding some variant of it
> > > yourself.
> > > Found with: find -type f -name "*.c" -o -name "*.h" | xargs perl -p -i -e
> > > 's/\bsizeof\s*\(\s*(\w+)\s*\)\s*\ /\s*sizeof\s*\(\s*\1\s*\[\s*0\s*\]\s*\)
> > > /ARRAY_SIZE(\1)/g' and manual check/verification.
> > > 
> > > Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
> > 
> > This should be submitted to the Intel ethernet driver maintainers.
> 
> Hi,
> 
> my script checks the output of get_maintainer scripts and only sends to "open
> list" entries.
> 
> The intel-wired-lan@lists.osuosl.org is moderated, so that's why the patch
> wasn't send there.
> 
> Strangely the lists for nouveau@lists.freedesktop.org and
> intel-gvt-dev@lists.freedesktop.org appears as open lists in the MAINTAINERS
> file but seems to be also moderated lists... At least I got some reply that my
> message awaits approval. Maybe an update to the MAINTAINERS file is missing
> here?
> 
> I may drop above check in my script and send to all mailing lists that
> get_maintainer.pl will return.

There's a difference between moderated and subscriber-only
entries in MAINTAINERS.

get_maintainers will by default list moderated lists and
not show subscriber-only lists unless using the -s switch.
