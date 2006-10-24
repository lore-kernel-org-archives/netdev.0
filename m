From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] [PATCH 1/3] adds iso3166-1 support
Date: Tue, 24 Oct 2006 10:30:17 +0200
Message-ID: <1161678617.2840.5.camel@ux156>
References: <43e72e890610231545n389d8a6dy89bb476101953234@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:21729 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965108AbWJXI3Q
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 04:29:16 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890610231545n389d8a6dy89bb476101953234@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> +static int load_iso3166_1(void) {
> +       int r = 0;
> +       r |= iso3166_1_add(4, "AF", "AFG", 
> +               "Afghanistan");
[...]

Why don't you make the table a static array, then you can use ARRAY_SIZE
and get rid of the whole list_head, not have it eat up code size and
mark it as read-only static data.

> +EXPORT_SYMBOL(iso3166_1_list);

Why export the list?

> +EXPORT_SYMBOL(get_iso3166_1_numeric);
> +EXPORT_SYMBOL(get_iso3166_1_alpha2);
> +EXPORT_SYMBOL(get_iso3166_1_alpha3);
> +EXPORT_SYMBOL(iso3166_1_exists);

Also, please put these along with the function.

johannes
