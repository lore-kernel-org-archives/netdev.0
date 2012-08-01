From: Denis Yefremov <yefremov.denis@gmail.com>
Subject: Re: wlcore: might_sleep operation in interrupt handler
Date: Wed, 1 Aug 2012 14:48:18 +0400
Message-ID: <CADKZ3FKTu7yT17EBHbHcgZhB-PZ-KECbGd2HZ-WfMb-t7qDwtg@mail.gmail.com>
References: <CADKZ3FKDw78ac9JPXJuw0s7Mqg1RrVfonbjXZ6zHmtwF2i5HoQ@mail.gmail.com>
	<1343765698.4474.10.camel@jlt3.sipsolutions.net>
	<CADKZ3FLs444RfLx=RyBPKs+Lza_mZHhT=zHauMt3BUnqAUtY0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Luciano Coelho <coelho@ti.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Eliad Peller <eliad@wizery.com>,
	Arik Nemtsov <arik@wizery.com>, Eyal Shapira <eyal@wizery.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADKZ3FLs444RfLx=RyBPKs+Lza_mZHhT=zHauMt3BUnqAUtY0w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry. My mistake. In this case it seems that sleep functions can
be called from thread_fn, since interrupt line is disabled globally.
And nothing bad will happen if you know that device can be
blocked for relatively long time.
