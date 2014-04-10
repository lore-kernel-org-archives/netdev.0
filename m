From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 1/5] wil6210: Convert to Kbuild
Date: Thu, 10 Apr 2014 13:06:11 +0200
Message-ID: <53467B23.6000407@suse.cz>
References: <1396946179-11677-1-git-send-email-qca_vkondrat@qca.qualcomm.com> <1397059601.14321.19.camel@joe-AO722> <534654D7.4080904@suse.cz> <1949326.Ead3K8R9Y2@lx-vladimir>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"John W . Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	netdev <netdev@vger.kernel.org>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47235 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030249AbaDJLGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 07:06:13 -0400
In-Reply-To: <1949326.Ead3K8R9Y2@lx-vladimir>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-04-10 12:23, Vladimir Kondratiev wrote:
> On Thursday, April 10, 2014 10:22:47 AM Michal Marek wrote:
>> Kbuild is a slightly better choice because it better describes the
>> content, but I don't think its needed to rename existing Makefiles just
>> because of that. Kbuild is needed in the toplevel directory or in
>> arch/*/, where Makefile has a different special meaning. The out of tree
>> build use case can be solved by a GNUmakefile.
>>
> 
> Originally, I followed the code found at
> drivers/scsi/osd/
> They have Kbuild for in-kernel use and Makefile for out-of-tree
> 
> But now I found, Documentation/kbuild/makefiles.txt says:
> ---cut---
> The preferred name for the kbuild files are 'Makefile' but 'Kbuild' can
> be used and if both a 'Makefile' and a 'Kbuild' file exists, then the 'Kbuild'
> file will be used.
> ---cut---
> 
> Accordingly to this, would you say I should drop this patch and go with
> GNUmakefile + Makefile for internal development? I am pretty neutral with
> this, just need to know what is the proper way.

It's up to you, since it's your driver :). But the trick with
GNUmakefile works with the driver as-is as well as any other driver, so
it might be easier just to use that.

Michal
