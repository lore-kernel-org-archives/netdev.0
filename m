From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/5] wil6210: Convert to Kbuild
Date: Wed, 09 Apr 2014 09:06:41 -0700
Message-ID: <1397059601.14321.19.camel@joe-AO722>
References: <1396946179-11677-1-git-send-email-qca_vkondrat@qca.qualcomm.com>
	 <1396946179-11677-2-git-send-email-qca_vkondrat@qca.qualcomm.com>
	 <1396973691.5212.3.camel@joe-AO722> <2146187.nt2BTDzSlP@lx-vladimir>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W . Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	netdev <netdev@vger.kernel.org>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>,
	Michal Marek <mmarek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0081.hostedemail.com ([216.40.44.81]:39440 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932786AbaDIQGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 12:06:48 -0400
In-Reply-To: <2146187.nt2BTDzSlP@lx-vladimir>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(adding Michal Marek)

On Wed, 2014-04-09 at 17:08 +0300, Vladimir Kondratiev wrote:
> On Tuesday, April 08, 2014 09:14:51 AM Joe Perches wrote:
> > On Tue, 2014-04-08 at 11:36 +0300, Vladimir Kondratiev wrote:
> > > Convert Makefile -> Kbuild,
> > > to make off-kernel development easier and less intrusive.
> > No drivers/net directory uses Kbuild.
> > Why should this?
> 
> because it makes it easier to do off-kernel development, and then
> move things to the proper location within the kernel without
> conflicting changes in the Makefile.
> As I understand, Kbuild is better choice because it is really not
> standalone "Makefile", it is intended to be included by the real
> Makefile. Thus, distinct name is better.
> Are there any reasons why not using Kbuild? I did not found
> guidelines when use Kbuild and when not.

Michal?  Any opinion?
