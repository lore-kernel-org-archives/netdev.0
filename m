From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Thu, 13 May 2004 15:19:16 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40A3CA34.60202@pobox.com>
References: <40A26FFA.4030701@pobox.com>	<20040512193349.GA14936@elte.hu>	<200405121947.i4CJlJm5029666@turing-police.cc.vt.edu>	<Pine.LNX.4.58.0405121255170.11950@bigblue.dev.mdolabs.com>	<200405122007.i4CK7GPQ020444@turing-police.cc.vt.edu>	<20040512202807.GA16849@elte.hu>	<20040512203500.GA17999@elte.hu>	<20040512205028.GA18806@elte.hu>	<20040512140729.476ace9e.akpm@osdl.org>	<20040512211748.GB20800@elte.hu>	<20040512221823.GK1397@holomorphy.com>	<61D92BA6-A504-11D8-BD91-000A95CD704C@wagland.net> <20040513121141.37f32035.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wli@holomorphy.com, greg@kroah.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, davidel@xmailserver.org,
	Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264453AbUEMTga@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Paul Wagland <paul@wagland.net>,
	mingo@elte.hu
In-Reply-To: <20040513121141.37f32035.akpm@osdl.org>
List-Id: netdev.vger.kernel.org


For whomever winds up doing this work, I have two requests:

* use a type-safe inline rather than purely a macro, as some drivers do
* replace msecs_to_jiffies() occurrences as well as MSECS_TO_JIFFIES() 
(and ditto for jiffies_to_msecs)
