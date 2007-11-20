From: "Guillaume Chazarain" <guichaz@yahoo.fr>
Subject: Re: [PATCH] proc: Fix the threaded /proc/self.
Date: Tue, 20 Nov 2007 23:58:14 +0100
Message-ID: <3d8471ca0711201458v16b05245kc408aa8021005050@mail.gmail.com>
References: <20071119191000.GA1560@elf.ucw.cz> <200711192304.25087.rjw@sisk.pl>
	 <4743026B.2020907@openvz.org>
	 <m11wakshyz.fsf@ebiederm.dsl.xmission.com>
	 <20071120215914.GE24156@elte.hu>
	 <m1k5ocr14n.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Pavel Emelyanov" <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, "Pavel Machek" <pavel@ucw.cz>,
	"kernel list" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, "Ingo Molnar" <mingo@elte.hu>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:47646 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbXKTW6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 17:58:16 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1275412ugc
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 14:58:15 -0800 (PST)
In-Reply-To: <m1k5ocr14n.fsf_-_@ebiederm.dsl.xmission.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Eric,

This fills a need I had to get the current TID in a Java program,
so I'm very interested in this change. OTOH, how will someone
not reading LKML discover that the current TID is now in
/proc/self and that it was not always the case?

I would put my 2 cents in /proc/self/task/self, this way TGID are
always in /proc and TID in /proc/TGID/task.

-- 
Guillaume
