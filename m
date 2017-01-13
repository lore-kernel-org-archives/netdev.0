From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v5 01/13] net: ethernet: aquantia: Make and
 configuration files.
Date: Thu, 12 Jan 2017 23:28:45 -0800
Message-ID: <1484292525.3065.29.camel@perches.com>
References: <cover.1484283610.git.vomlehn@texas.net>
         <fe1664e502d28bcb6a5689787b8000e6c9288307.1484283610.git.vomlehn@texas.net>
         <1484283977.3065.24.camel@perches.com>
         <a1dcfa57-97a1-dc20-6d8d-60cba3be3a56@texas.net>
         <1484287161.3065.27.camel@perches.com>
         <ce83519e-18bf-b202-7a0f-c217ab8aa189@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: David VomLehn <vomlehn@texas.net>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0252.hostedemail.com ([216.40.44.252]:49401 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751099AbdAMH2t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 02:28:49 -0500
In-Reply-To: <ce83519e-18bf-b202-7a0f-c217ab8aa189@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-12 at 22:57 -0800, David VomLehn wrote:
> On 01/12/2017 09:59 PM, Joe Perches wrote:
> > On Thu, 2017-01-12 at 21:24 -0800, David VomLehn wrote:
> > > On 01/12/2017 09:06 PM, Joe Perches wrote:
> > > > On Thu, 2017-01-12 at 21:02 -0800, Alexander Loktionov wrote:
> > > > > From: David VomLehn <vomlehn@texas.net>
> > > > > 
> > > > > Patches to create the make and configuration files.
> > > > 
> > > > This patch should _really_ be the last in the series
> > > > not the first.
> > > > 
> > > 
> > > Could you explain the basis for this? By convention, we put tables of
> > > content at the beginning of books and only indices at the back.
> > > Analogously, make and config files can be used to established the
> > > context for what follows, making it easier to understand. Once
> > > committed, of course, the order no longer matters except as bisection is
> > > concerned.
> > 
> > As I wrote the first time:
> > 
> > On Tue, 2016-12-27 at 08:15 -0800, Joe Perches wrote:
> > > On Tue, 2016-12-27 at 05:17 -0800, David VomLehn wrote:
> > > > Patches to create the make and configuration files.
> > 
> > []
> > > Patch 1 will not build if CONFIG_AQTION is enabled.
> > > Patch 1/12 should be reordered to be patch 12/12 and
> > > all the other patches moved up appropriately.
> > 
> > You don't create the files until later patches.
> > 
> > If you applied just this first patch and tried to
> > add CONFIG_AQTION=y to the .config, make fails.
> > 
> > That's bad for git bisect.
> > Every patch in this series should build properly.
> > 
> > If you delay the adding of the Makefile and Kconfig
> > until all the files are added, then it'd bisect fine.
> 
> Please go back and re-read the latest patches; I think you will find 
> your concern about CONFIG_AQTION addressed in the v5 patchset. The 01/13 
> patch no longer has the changes to Makefile and Kconfig in 
> drivers/net/ethernet that will pull in the Makefile and Kconfig from 
> drivers/net/ethernet/aquantia. Those changes are now in the 13/13 patch, 
> which should make it bisectable. If I am missing something, please let 
> me know.

Well fine then.

I just looked subject titles and didn't notice that change.

cheers, Joe
