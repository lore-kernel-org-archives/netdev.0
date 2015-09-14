From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [fw filter]: Broken! fw mark based tc class selection not working
Date: Mon, 14 Sep 2015 08:28:05 -0400
Message-ID: <55F6BD55.6080503@mojatatu.com>
References: <CAA5aLPhvkEPpDhaxSNWnGHU2H0WmCaYhbo-fYKP8+Xzka3-q=g@mail.gmail.com>
 <CAHA+R7P5jTGBof-oObzJ0SidRr17fKLGjoMkk0-VYzuSLjawZg@mail.gmail.com>
 <CAA5aLPgCqOXU3vw6moSvADuOc4Q_TM2iJLHjSH0O8NwYJJ1t7g@mail.gmail.com>
 <CAHA+R7N6rTS5rmALk_2FxUXc0s9Ni4snJQ52tS3imaA6hotdHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <cwang@twopensource.com>,
	Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36474 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbbINM2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 08:28:10 -0400
Received: by igcrk20 with SMTP id rk20so85849099igc.1
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 05:28:09 -0700 (PDT)
In-Reply-To: <CAHA+R7N6rTS5rmALk_2FxUXc0s9Ni4snJQ52tS3imaA6hotdHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/15 20:00, Cong Wang wrote:
> On Fri, Sep 11, 2015 at 3:24 PM, Akshat Kakkar <akshat.1984@gmail.com> wrote:

> Hmm, I didn't know that before either. Looks like my tp->init change
> breaks it.
>
> Could you try the following patch?
>

I would just make init() empty for this classifier (return 0?).
If someone wants to add classids ids, change() is available.
The most common (efficient) use case is what Akshat shows.
So even the check in the classify should optimize for that i.e
if (head == NULL)
     do old method
else
     ...

cheers,
jamal
