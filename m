From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next RFC] ipv4 neigh: match add/del dev lookup
 behaviour to SIOCSARP/SIOCDARP
Date: Tue, 24 Feb 2015 06:38:31 -0800
Message-ID: <1424788711.5565.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424756572-29379-1-git-send-email-roopa@cumulusnetworks.com>
	 <9B0331B6EBBD0E4684FBFAEDA55776F9189654A5@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"hadi@mojatatu.com" <hadi@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:65232 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbbBXOid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 09:38:33 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so27041447igq.0
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 06:38:33 -0800 (PST)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F9189654A5@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-24 at 14:01 +0000, Rosen, Rami wrote:

> We can exit the method at this point with "return PTR_ERR(rt)" because we are assured at this point that dev is NULL.

Not sure it matters if dev is NULL or not :

We hold RTNL, and we do not have to hold/release dev.
