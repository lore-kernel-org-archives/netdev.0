From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 0/3] NetLabel: add the remaining CIPSO tag types from the IETF draft
Date: Wed, 29 Nov 2006 10:55:18 -0800 (PST)
Message-ID: <889357.90007.qm@web36607.mail.mud.yahoo.com>
References: <20061129181817.505281000@hp.com>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web36607.mail.mud.yahoo.com ([209.191.85.24]:42928 "HELO
	web36607.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S967544AbWK2SzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 13:55:20 -0500
To: paul.moore@hp.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov
In-Reply-To: <20061129181817.505281000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- paul.moore@hp.com wrote:

> This patchset consists of three patches that add
> support for the remaining two
> tag types from the CIPSO draft specification, the
> enumerated and range tags.
> The most significant part about adding these two
> tags is that NetLabel now has
> the ability to represent more than 240 categories
> (limitation imposed by the
> current restricted bitmap tag).
> 
> In addition, the first patch in the set converts
> NetLabel's contiguous char
> string category bitmap stored in network friendly
> bit/byte order into a sparse
> bitmap stored in host friendly bit/byte order. 
> While this change was not
> required to support the new CIPSO tags, it should
> make life much easier as the
> old category bitmap would have proven problematic as
> the number of usable
> categories increases with the new tag types.  It
> also has a side effect of
> making the LSM specific code much less ugly.

Fabulous. Thank you.


Casey Schaufler
casey@schaufler-ca.com
