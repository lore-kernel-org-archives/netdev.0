From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH iproute2 net-next v4 0/5] bridge: json support for fdb and
 vlan show
Date: Sat, 25 Jun 2016 09:20:11 +0300
Message-ID: <CAKoUAr=RAqQDxzMFRUr3yOTL_7dV9xAb5RYZCA9UUVH5ic-5AQ@mail.gmail.com>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
 <20160622145344.GE2068@nanopsycho.orion> <20160622111047.1523b06f@xeon-e3>
 <20160622200055.GA1977@nanopsycho.orion> <CAJieiUjUy-uhw=fONKvsnaHEu_8WcLiJhBL30Aze8F4_-d2gww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Julien Fortin <julien@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36357 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbcFYGUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 02:20:14 -0400
Received: by mail-lf0-f68.google.com with SMTP id a2so23745598lfe.3
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 23:20:13 -0700 (PDT)
In-Reply-To: <CAJieiUjUy-uhw=fONKvsnaHEu_8WcLiJhBL30Aze8F4_-d2gww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

>Also, for external automation and orchestration tools (to whom this
>patch-set is addressed),
>there is no reason for them to write and maintain their own tools
>using netlink when they
>can use iproute2 directly to create a link or query its properties.

+1 for this, seems very reasonable,

Just want to remind us all, in recent netdev 1.1 conference in Seville
(Feb 2016), Damascene Joachimpillai (DJ) from Verizon gave a talk
("Linux Networking and Data Center Operations Challenges"); IIRC, he
mentioned that he misses a REST API to the Linux Kernel networking
stack control plane. And it seems that Rest API and JSON (and maybe
other APIs, like python based APIs) are natural candidates for such an
interface nowadays.


Regards,
Rami Rosen
http://ramirose.wix.com/ramirosen
