From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC][PATCH][v5] net/ethtool: Add support for the ethtool
	feature to flash firmware image from a specified file.
Date: Wed, 02 Sep 2009 18:00:19 +0100
Message-ID: <1251910819.2781.5.camel@achroite>
References: <20090821165416.GA17102@serverengines.com>
	 <20090902162241.GB23228@serverengines.com>  <4A9EA1D7.8090002@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ajit Khaparde <ajitk@serverengines.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:52723 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751582AbZIBRAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 13:00:24 -0400
In-Reply-To: <4A9EA1D7.8090002@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-02 at 12:48 -0400, Jeff Garzik wrote:
> On 09/02/2009 12:22 PM, Ajit Khaparde wrote:
> > On 21/08/09 22:24 +0530, Ajit Khaparde wrote:
> >> This patch adds support to flash a firmware image to a device using ethtool.
> >> The driver gets the filename of the firmware image and flashes the image
> >> using the request firmware path.
> >>
> >> The region "on the chip" to be flashed can be specified by an option.
> >> It is upto the device driver to enumerate the region number passed by ethtool,
> >> to the region to be flashed.
> >>
> >> The default behavior is to flash all the regions on the chip.
> > David,
> > Is this patch good enough for being accepted? Please let me know if any more
> > work has to be done on this.
> >
> > I want to send the changes to the be2net driver which would use this
> > new ethtool feature.  Any ETA for applying the patch to the git tree?
> > I will schedule my driver patch according to that.
> 
> BTW, don't forget to update the ethtool userland utility as well,
> git://git.kernel.org/pub/scm/network/ethtool/ethtool.git

Ajit also posted a patch for ethtool on 21 August:
<http://article.gmane.org/gmane.linux.network/135785>.

Also, I sent you a series of patches back in April that you have
apparently ignored, although the corresponding kernel patches are in
2.6.31: <http://thread.gmane.org/gmane.linux.network/127025>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

