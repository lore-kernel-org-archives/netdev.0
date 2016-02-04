From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Thu, 4 Feb 2016 14:26:23 +0100
Message-ID: <20160204132622.GB2198@nanopsycho.orion>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <20160203143133.1b70bcb5@redhat.com>
 <20160203133356.GA2219@nanopsycho.orion>
 <56B219FA.7080208@iogearbox.net>
 <56B35089.4000707@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37140 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbcBDN0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 08:26:25 -0500
Received: by mail-wm0-f44.google.com with SMTP id g62so4341857wme.0
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 05:26:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56B35089.4000707@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 04, 2016 at 02:22:17PM CET, hannes@stressinduktion.org wrote:
>On 03.02.2016 16:17, Daniel Borkmann wrote:
>>On 02/03/2016 02:33 PM, Jiri Pirko wrote:
>>>Wed, Feb 03, 2016 at 02:31:33PM CET, brouer@redhat.com wrote:
>>>>On Wed,  3 Feb 2016 11:47:56 +0100
>>>>Jiri Pirko <jiri@resnulli.us> wrote:
>>>>>From: Jiri Pirko <jiri@mellanox.com>
>>[...]
>>>>>It is available here:
>>>>>https://github.com/jpirko/devlink
>>>>
>>>>IHMO this very short command name "dl" is not an advantage.  It is
>>>>simply too unspecific and short for a good Google search.  E.g. when
>>>>searching for good examples for using "dl".  I think "devlink" would be
>>>>better.  If you like short commands do: alias dl="devlink"
>>>
>>>I was thinking about using "devlink". Decided to go with shortened
>>>version so this is in-line with "ip". But you have a point.
>>
>>Btw, if you add this tool into iproute2 (which would be preferred), then
>>probably dl should be ok (and easier retrievable in that relation).
>
>This doesn't seem to be too much related to networking? Why can't something
>like this be in sysfs?

It is related to networking quite bit. There has been couple of
iteration of this, including sysfs and configfs implementations. There
has been a consensus reached that this should be done by netlink. I
believe netlink is really the best for this purpose. Sysfs is not a good
idea.
