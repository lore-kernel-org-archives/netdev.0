From: "Anand Kumria" <wildfire@progsoc.org>
Subject: Re: [RFC] [PATCH 1/3] adds iso3166-1 support
Date: Wed, 25 Oct 2006 01:44:52 +0000 (UTC)
Message-ID: <ehmfij$99h$1@sea.gmane.org>
References: <43e72e890610231545n389d8a6dy89bb476101953234@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:61909 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1161330AbWJYBz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 21:55:57 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GcXu4-0007Si-GQ
	for netdev@vger.kernel.org; Wed, 25 Oct 2006 03:50:23 +0200
Received: from 88-110-175-230.dynamic.dsl.as9105.com ([88.110.175.230])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 03:50:00 +0200
Received: from wildfire by 88-110-175-230.dynamic.dsl.as9105.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 03:50:00 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Oct 2006 18:45:23 -0400, Luis R. Rodriguez wrote:

> iso3166-1
> 
> ISO 3166-1, as part of the ISO 3166 standard, provides codes for the names
> of countries and dependent areas. It was first published in 1974 by
> the International Organization for Standardization (ISO) and defines three
> different codes for each area:

[snip]

+	r |= iso3166_1_add(887, "YE", "YEM", 
+		"Yemen");
+	r |= iso3166_1_add(891, "CS", "SCG", 
+		"Serbia and Montenegro");
+	r |= iso3166_1_add(894, "ZM", "ZMB", 
+		"Zambia");


According to the ISO, at:

<http://www.iso.org/iso/en/commcentre/pressreleases/2006/Ref1031.html>

and

<http://www.iso.org/iso/en/prods-services/iso3166ma/03updates-on-iso-3166/nlv12-div.html>

Serbia and Montenegro have been allocated new codes, RS and ME respectively.

Is this ISO3166 stuff supposed to track the standard? If so, what happens when a country splits or two join together?

Will that require lock-step updates to user-space, or will it be insulated byt this changes?

Regards,
Anand

