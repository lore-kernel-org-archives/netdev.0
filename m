From: "Justin Mattock" <justinmattock@gmail.com>
Subject: Re: stuck tcp connections 2.6.26-rc7
Date: Wed, 25 Jun 2008 06:25:45 +0000
Message-ID: <dd18b0c30806242325j4f6d1b1bw1cdde7ea08ad12e2@mail.gmail.com>
References: <dd18b0c30806221109t2ff73f9ai52f6716748648a79@mail.gmail.com>
	 <20080622205927.301501e7.akpm@linux-foundation.org>
	 <dd18b0c30806230013x5446991bi9eba7623ffaae131@mail.gmail.com>
	 <g3ol3u$li2$1@ger.gmane.org>
	 <dd18b0c30806231845s1cc6151coc2a4f26ed3521500@mail.gmail.com>
	 <2c0942db0806241016o3be1dae8i433da13697c4531c@mail.gmail.com>
	 <dd18b0c30806241303g755e3881y4ea7d403eb2922fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Didier Raboud" <didier@raboud.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Ray Lee" <ray-lk@madrabbit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:28603 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbYFYGZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 02:25:46 -0400
Received: by an-out-0708.google.com with SMTP id d40so785000and.103
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 23:25:45 -0700 (PDT)
In-Reply-To: <dd18b0c30806241303g755e3881y4ea7d403eb2922fc@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2008 at 8:03 PM, Justin Mattock <justinmattock@gmail.com> wrote:
> On Tue, Jun 24, 2008 at 5:16 PM, Ray Lee <ray-lk@madrabbit.org> wrote:
>> 2008/6/23 Justin Mattock <justinmattock@gmail.com>:
>>> On Mon, Jun 23, 2008 at 5:04 PM, Didier Raboud <didier@raboud.com> wrote:
>>>> -----BEGIN PGP SIGNED MESSAGE-----
>>>> Hash: SHA1
>>>>
>>>> Justin Mattock wrote:
>>>>
>>>>> On Mon, Jun 23, 2008 at 3:59 AM, Andrew Morton
>>>>> <akpm@linux-foundation.org> wrote:
>>>>>> On Sun, 22 Jun 2008 18:09:16 +0000 "Justin Mattock"
>>>>>> <justinmattock@gmail.com> wrote:
>>>>>>
>>>>>>> Hello; I too am experiencing internet connectivity problems, for  a
>>>>>>> while I thought
>>>>>>> It was due to low bandwidth(or being ddos attacked) but yesterday I
>>>>>>> noticed with watch netstat -ntu
>>>>>>> send-Q was stuck on a number; the connection would not go to TIME_WAIT
>>>>>>> resulting in music to pause, and t.v. to freeze.
>>>>>>> In my experiences running xmms streaming music is fine, no problems,
>>>>>>> but as soon as
>>>>>>> you watch something with flash player the stream start's getting
>>>>>>> really bad. In the past with older kernel's
>>>>>>> I usually can watch t.v.(with flash) and stream music at the same time
>>>>>>> without any trouble.
>>>>>>> lately I've been Running the kernel in No forced Preemption with a
>>>>>>> time frequency at 100. having the kernel set in this mode really shows
>>>>>>> the connection problems, but if I change the preemption to another,
>>>>>>> and bump up the timer frequency the poor internet connection is not as
>>>>>>> bad(or stuck tcp) but still prevalent. more pops in the music, and
>>>>>>> sudden internet loss for around five seconds, then goes back
>>>>>>> So from over here streaming music has no problems from what I can see,
>>>>>>> but as soon as I watch media, it becomes a mess.
>>>>>>
>>>>>> (cc netdev)
>>>>>>
>>>>>
>>>>>
>>>>> Cool, Thanks for sending the cc
>>>>> regards;
>>>>
>>>> Hi,
>>>>
>>>> I get something like a similar bug: when pinging my local gateway, I loose
>>>> packets (over wifi (iwl3945) ). Before the update to 2.6.26-rc7 (Debian), I
>>>> had no such issues (which makes Internet browsing working but weirdly).
>>>>
>>>> I can't know for sure that my bug is related to the above, but suppose so.
>>>> Please ask for details !
>>>>
>>>> Regards,
>>>>
>>>> Didier Raboud
>>>> - --
>>>
>>> Cool;(cool as in I'm not the only one,not cool for sh*%y internet connections)
>>> there is something definitely happening with the tcp connection.,
>>> After looking more at the situation
>>> I get a good connection when just streaming music, but as soon as I
>>> watch with flash or even search through firefox
>>> I'm getting a dead period of no internet, and then a few seconds later
>>> no problems.Almost as if some timer in the code is missing something
>>> or not firing off at the right time.
>>> At this point I'm still uncertain with what is happening.
>>> regards;
>>
>> If you leave a ping running as root to your local gateway from a
>> console ( nice -n -10 ping -i 0.5 192.168.1.1
>>  or whichever ip ), does it show dropouts?
>>
>
> I'll give that a try and see what happens.
> regards;
>
> --
> Justin P. Mattock
>

Hmm, well I really don't know what to say with the tcp
connection(issue), It seems to go in and out of phases i.g.
at first running music, and t.v.(through flash) there's moments of
pauses,(around 5 secs or so) then after a while
the tcp seems to even itself out, but then after a while(5min or so)
the same pauses begin. Maybe due to some missing packet, or
some deadlock if this is proper to say.
regards;

-- 
Justin P. Mattock
