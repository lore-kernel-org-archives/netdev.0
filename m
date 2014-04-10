From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 1/5] wil6210: Convert to Kbuild
Date: Thu, 10 Apr 2014 10:22:47 +0200
Message-ID: <534654D7.4080904@suse.cz>
References: <1396946179-11677-1-git-send-email-qca_vkondrat@qca.qualcomm.com>	 <1396946179-11677-2-git-send-email-qca_vkondrat@qca.qualcomm.com>	 <1396973691.5212.3.camel@joe-AO722> <2146187.nt2BTDzSlP@lx-vladimir> <1397059601.14321.19.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W . Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43646 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964832AbaDJIWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 04:22:50 -0400
In-Reply-To: <1397059601.14321.19.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-04-09 18:06, Joe Perches wrote:
> (adding Michal Marek)
> 
> On Wed, 2014-04-09 at 17:08 +0300, Vladimir Kondratiev wrote:
>> On Tuesday, April 08, 2014 09:14:51 AM Joe Perches wrote:
>>> On Tue, 2014-04-08 at 11:36 +0300, Vladimir Kondratiev wrote:
>>>> Convert Makefile -> Kbuild,
>>>> to make off-kernel development easier and less intrusive.
>>> No drivers/net directory uses Kbuild.
>>> Why should this?
>>
>> because it makes it easier to do off-kernel development, and then
>> move things to the proper location within the kernel without
>> conflicting changes in the Makefile.

You can create a GNUmakefile for this purpose, it takes precedence over
Makefile.


>> As I understand, Kbuild is better choice because it is really not
>> standalone "Makefile", it is intended to be included by the real
>> Makefile. Thus, distinct name is better.
>> Are there any reasons why not using Kbuild? I did not found
>> guidelines when use Kbuild and when not.

Kbuild is a slightly better choice because it better describes the
content, but I don't think its needed to rename existing Makefiles just
because of that. Kbuild is needed in the toplevel directory or in
arch/*/, where Makefile has a different special meaning. The out of tree
build use case can be solved by a GNUmakefile.

Michal
