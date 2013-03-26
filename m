From: Serge Hallyn <serge.hallyn@ubuntu.com>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Tue, 26 Mar 2013 09:17:47 -0500
Message-ID: <20130326141747.GA18692@sergelap>
References: <CD773D0D.7614%blourdel@juniper.net>
 <87wqsu72r6.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benoit Lourdelet <blourdel@juniper.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:53003 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758355Ab3CZOR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 10:17:57 -0400
Content-Disposition: inline
In-Reply-To: <87wqsu72r6.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Specifing the names would dramatically improve your creation
> performance.  It should only take you about 10s for 5000 veth pairs.
> But you have to specify the names.

Thanks, Eric.  I'm going to update lxc to always specify names for
the veth pairs, rather than only when they are requested by the
user's configuration file.

-serge
