From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Virtual ethernet tunnel
Date: Wed, 13 Jun 2007 13:12:19 +0200
Message-ID: <466FD113.3070909@trash.net>
References: <4666CEAA.8010903@openvz.org> <4666D296.2000002@trash.net> <4667BD1D.9080905@openvz.org> <466D3466.10306@trash.net> <466FB7E7.4060201@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60901 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756281AbXFMLPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 07:15:34 -0400
In-Reply-To: <466FB7E7.4060201@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Patrick McHardy wrote:
> 
>>The question is how to proceed. I haven't read all mails yet, but it
>>seems there is some disagreement about whether to create all devices
>>in the same namespace and move them later or create them directly in
> 
> 
> The agreement was that we can make any of the above. We can create
> booth devices in the init namespace and then move one of them into the
> desired namespace, or we can explicitly specify which namespace to create
> the pair in.


I'm going to push my latest patches to Dave today, the easiest way is
probably is you just add whatever you need to the API afterwards.

