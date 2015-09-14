From: Cong Wang <cwang@twopensource.com>
Subject: Re: [fw filter]: Broken! fw mark based tc class selection not working
Date: Mon, 14 Sep 2015 15:04:01 -0700
Message-ID: <CAHA+R7NCn0OsLUdVZbvJ_B8tJGVJ9_Pys_FARPM2Z-xdS4-_Uw@mail.gmail.com>
References: <CAA5aLPhvkEPpDhaxSNWnGHU2H0WmCaYhbo-fYKP8+Xzka3-q=g@mail.gmail.com>
	<CAHA+R7P5jTGBof-oObzJ0SidRr17fKLGjoMkk0-VYzuSLjawZg@mail.gmail.com>
	<CAA5aLPgCqOXU3vw6moSvADuOc4Q_TM2iJLHjSH0O8NwYJJ1t7g@mail.gmail.com>
	<CAHA+R7N6rTS5rmALk_2FxUXc0s9Ni4snJQ52tS3imaA6hotdHw@mail.gmail.com>
	<55F6BD55.6080503@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Akshat Kakkar <akshat.1984@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:33520 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbINWED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 18:04:03 -0400
Received: by ykft14 with SMTP id t14so15357482ykf.0
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 15:04:02 -0700 (PDT)
In-Reply-To: <55F6BD55.6080503@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 5:28 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 09/11/15 20:00, Cong Wang wrote:
>>
>> On Fri, Sep 11, 2015 at 3:24 PM, Akshat Kakkar <akshat.1984@gmail.com>
>> wrote:
>
>
>> Hmm, I didn't know that before either. Looks like my tp->init change
>> breaks it.
>>
>> Could you try the following patch?
>>
>
> I would just make init() empty for this classifier (return 0?).
> If someone wants to add classids ids, change() is available.
> The most common (efficient) use case is what Akshat shows.
> So even the check in the classify should optimize for that i.e
> if (head == NULL)
>     do old method
> else
>     ...

That is exactly the original code. But it is not readable at all,
at least I still missed it when I touched the tp->init() part. :(
Having a boolean doesn't harm anything.
