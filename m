From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [fw filter]: Broken! fw mark based tc class selection not working
Date: Thu, 17 Sep 2015 08:16:31 -0400
Message-ID: <55FAAF1F.6000206@mojatatu.com>
References: <CAA5aLPhvkEPpDhaxSNWnGHU2H0WmCaYhbo-fYKP8+Xzka3-q=g@mail.gmail.com>
 <CAHA+R7P5jTGBof-oObzJ0SidRr17fKLGjoMkk0-VYzuSLjawZg@mail.gmail.com>
 <CAA5aLPgCqOXU3vw6moSvADuOc4Q_TM2iJLHjSH0O8NwYJJ1t7g@mail.gmail.com>
 <CAHA+R7N6rTS5rmALk_2FxUXc0s9Ni4snJQ52tS3imaA6hotdHw@mail.gmail.com>
 <55F6BD55.6080503@mojatatu.com>
 <CAHA+R7NCn0OsLUdVZbvJ_B8tJGVJ9_Pys_FARPM2Z-xdS4-_Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Akshat Kakkar <akshat.1984@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34878 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbIQMQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 08:16:34 -0400
Received: by ioiz6 with SMTP id z6so19326096ioi.2
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 05:16:34 -0700 (PDT)
In-Reply-To: <CAHA+R7NCn0OsLUdVZbvJ_B8tJGVJ9_Pys_FARPM2Z-xdS4-_Uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/15 18:04, Cong Wang wrote:

>
> That is exactly the original code. But it is not readable at all,
> at least I still missed it when I touched the tp->init() part. :(
> Having a boolean doesn't harm anything.

The default should really be no head alloced (given that is the
main use case).
The other part you can make more readable.

cheers,
jamal
