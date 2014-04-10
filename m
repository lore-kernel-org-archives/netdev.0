From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [PATCH 1/5] wil6210: Convert to Kbuild
Date: Thu, 10 Apr 2014 13:23:18 +0300
Message-ID: <1949326.Ead3K8R9Y2@lx-vladimir>
References: <1396946179-11677-1-git-send-email-qca_vkondrat@qca.qualcomm.com> <1397059601.14321.19.camel@joe-AO722> <534654D7.4080904@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Joe Perches <joe@perches.com>,
	"John W . Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <wil6210@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>
To: Michal Marek <mmarek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:2440 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965637AbaDJKXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 06:23:23 -0400
In-Reply-To: <534654D7.4080904@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, April 10, 2014 10:22:47 AM Michal Marek wrote:
> On 2014-04-09 18:06, Joe Perches wrote:
> > (adding Michal Marek)
> > 
> > On Wed, 2014-04-09 at 17:08 +0300, Vladimir Kondratiev wrote:
> >> On Tuesday, April 08, 2014 09:14:51 AM Joe Perches wrote:
> >>> On Tue, 2014-04-08 at 11:36 +0300, Vladimir Kondratiev wrote:
> >>>> Convert Makefile -> Kbuild,
> >>>> to make off-kernel development easier and less intrusive.
> >>> No drivers/net directory uses Kbuild.
> >>> Why should this?
> >>
> >> because it makes it easier to do off-kernel development, and then
> >> move things to the proper location within the kernel without
> >> conflicting changes in the Makefile.
> 
> You can create a GNUmakefile for this purpose, it takes precedence over
> Makefile.
> 
> 
> >> As I understand, Kbuild is better choice because it is really not
> >> standalone "Makefile", it is intended to be included by the real
> >> Makefile. Thus, distinct name is better.
> >> Are there any reasons why not using Kbuild? I did not found
> >> guidelines when use Kbuild and when not.
> 
> Kbuild is a slightly better choice because it better describes the
> content, but I don't think its needed to rename existing Makefiles just
> because of that. Kbuild is needed in the toplevel directory or in
> arch/*/, where Makefile has a different special meaning. The out of tree
> build use case can be solved by a GNUmakefile.
> 

Originally, I followed the code found at
drivers/scsi/osd/
They have Kbuild for in-kernel use and Makefile for out-of-tree

But now I found, Documentation/kbuild/makefiles.txt says:
---cut---
The preferred name for the kbuild files are 'Makefile' but 'Kbuild' can
be used and if both a 'Makefile' and a 'Kbuild' file exists, then the 'Kbuild'
file will be used.
---cut---

Accordingly to this, would you say I should drop this patch and go with
GNUmakefile + Makefile for internal development? I am pretty neutral with
this, just need to know what is the proper way.

Thanks, Vladimir 
