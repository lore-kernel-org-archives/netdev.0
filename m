From: "Ann Davis" <andavis@suse.com>
Subject: Re: blog post, other stuff
Date: Wed, 15 Aug 2012 09:33:53 -0600
Message-ID: <502B6D01020000D6000E54A9@novprvoes0310.provo.novell.com>
References: <CAB=NE6VFsJrXznJDU4w2Oq1gQkMjLTtJPtTk2hhL0V1FPLpaYQ@mail.gmail.com>
 <502A3384020000D6000E532B@novprvoes0310.provo.novell.com>
 <CAB=NE6VXfs-=B+j_pFXPo+Ux99hHSFuYJB+_JKphtEYMyhAb7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: "Luis R. Rodriguez" <mcgrof@frijolero.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from novprvoes0310.provo.novell.com ([137.65.248.74]:38949 "EHLO
	novprvoes0310.provo.novell.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752268Ab2HOPyB convert rfc822-to-8bit
	(ORCPT <rfc822;groupwise-netdev@vger.kernel.org:2:1>);
	Wed, 15 Aug 2012 11:54:01 -0400
In-Reply-To: <CAB=NE6VXfs-=B+j_pFXPo+Ux99hHSFuYJB+_JKphtEYMyhAb7A@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luis,

>>> On 8/14/2012 at 04:44 PM, in message
<CAB=NE6VXfs-=B+j_pFXPo+Ux99hHSFuYJB+_JKphtEYMyhAb7A@mail.gmail.com>, "Luis R.
Rodriguez" <mcgrof@frijolero.org> wrote: 
> On Tue, Aug 14, 2012 at 10:16 AM, Ann Davis <andavis@suse.com> wrote:
>> Luis,
>>
>>>>> On 8/13/2012 at 10:45 PM, in message
>> <CAB=NE6VFsJrXznJDU4w2Oq1gQkMjLTtJPtTk2hhL0V1FPLpaYQ@mail.gmail.com>, "Luis R.
>> Rodriguez" <mcgrof@frijolero.org> wrote:
>>> Here is:
>>>
>>> http://www.do-not-panic.com/2012/08/automatically-backporting-linux-kernel.h
>>> tml
>>>
>>> Does this work?
>>
>> Yes, I think this is great.  Are you ok with me sending it on to Amanda and 
> Jennifer along with a short "Here's some new stuff happening in the Driver 
> Backport Workgroup" intro?  I don't know if they will want to just pull in 
> the text or have a link to your mcgrof site; do you have a preference?  I 
> think they should just pull in the text and reference your site if needed 
> (less clicks means more likelihood of people reading).
> 
> Whatever works, so I just updated the blog to reflect all the
> documentation updates I've made. The backports.wiki.kernel.org page
> now has all the documentation necessary and is very agnostic to any
> subsystem. I've also renamed compat-wireless.git tree to
> compat-drivers.git and also set information on the wiki about the
> first G+ hangout scheduled for Sept 4th.

Sounds great, I'll take care of getting the blog info to Amanda and Jennifer.

Yep, when I did a checkout yesterday I noticed that it's now compat-drivers.  Builds fine on my SLE 11 SP2 box (3.0.26 kernel).  :)  On this topic, I've thought some more about what would be the best way to make sure the project continually builds for our openSUSE and SLE kernels.  My latest idea is to pull the code into a compat-drivers project on our Open Build Service (OBS: http://build.opensuse.org ) .  Have you heard of OBS?  If I put the code in there then I could do continual git pulls and builds for all our openSUSE and SLE versions.  (It can also build for other distros like RHEL, Ubuntu, etc. but my focus would be on our distros).  Thoughts?  I guess the basic question is whether it makes more sense to add lots of distro kernels into your builds or whether your builds should focu
 s on kernel.org kernels and then different distro vendors take care of ensuring that the project builds for their own kernels.  Maybe this discussion belongs on the list but I'm trying to get an initial feel for the overall design...

On another note, have you heard anything more from Konstantin re. whether kernel.org would accept hardware w/o a support contract?  My HP contact here asked about the status.

Thanks much,

Ann


> 
>   Luis
