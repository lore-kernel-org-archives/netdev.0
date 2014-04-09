From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [PATCH 1/5] wil6210: Convert to Kbuild
Date: Wed, 9 Apr 2014 17:08:49 +0300
Message-ID: <2146187.nt2BTDzSlP@lx-vladimir>
References: <1396946179-11677-1-git-send-email-qca_vkondrat@qca.qualcomm.com> <1396946179-11677-2-git-send-email-qca_vkondrat@qca.qualcomm.com> <1396973691.5212.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "John W . Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <wil6210@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:38087 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933342AbaDIOI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 10:08:56 -0400
In-Reply-To: <1396973691.5212.3.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, April 08, 2014 09:14:51 AM Joe Perches wrote:
> On Tue, 2014-04-08 at 11:36 +0300, Vladimir Kondratiev wrote:
> > Convert Makefile -> Kbuild,
> > to make off-kernel development easier and less intrusive.
> 
> No drivers/net directory uses Kbuild.
> 
> Why should this?

because it makes it easier to do off-kernel development, and then
move things to the proper location within the kernel without
conflicting changes in the Makefile.
As I understand, Kbuild is better choice because it is really not
standalone "Makefile", it is intended to be included by the real
Makefile. Thus, distinct name is better.
Are there any reasons why not using Kbuild? I did not found
guidelines when use Kbuild and when not.

> 
> > Signed-off-by: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
> > ---
> >  drivers/net/wireless/ath/wil6210/Kbuild   | 18 ++++++++++++++++++
> >  drivers/net/wireless/ath/wil6210/Makefile | 18 ------------------
> 
> If you send renaming patches, please use
> git format-patch -M

Sure I will. Thanks for mentioning this.

Thanks, Vladimir
