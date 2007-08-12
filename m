From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [RFD] Layering: Use-Case Composers (was: DRBD - what is it,
 anyways? [compare with e.g. NBD + MD raid])
Date: Sun, 12 Aug 2007 13:28:38 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr>
References: <200708121335.17267.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, linux-raid@vger.kernel.org
To: Al Boldi <a1426z@gawab.com>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <200708121335.17267.a1426z@gawab.com>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 12 2007 13:35, Al Boldi wrote:
>Lars Ellenberg wrote:
>> meanwhile, please, anyone interessted,
>> the drbd paper for LinuxConf Eu 2007 is finalized.
>> http://www.drbd.org/fileadmin/drbd/publications/
>> drbd8.linux-conf.eu.2007.pdf
>>
>> but it does give a good overview about what DRBD actually is,
>> what exact problems it tries to solve,
>> and what developments to expect in the near future.
>>
>> so you can make up your mind about
>>  "Do we need it?", and
>>  "Why DRBD? Why not NBD + MD-RAID?"

I may have made a mistake when asking for how it compares to NBD+MD.
Let me retry: what's the functional difference between
GFS2 on a DRBD .vs. GFS2 on a DAS SAN?

>Now, shared remote block access should theoretically be handled, as does 
>DRBD, by a block layer driver, but realistically it may be more appropriate 
>to let it be handled by the combining end user, like OCFS or GFS.


	Jan
-- 
