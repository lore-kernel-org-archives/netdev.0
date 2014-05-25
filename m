From: David Newall <davidn@davidnewall.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Sun, 25 May 2014 16:07:19 +0930
Message-ID: <53818F9F.90307@davidnewall.com>
References: <53803488.6000400@davidnewall.com>	<20140524.134356.992924324126016022.davem@davemloft.net>	<53815623.8020506@davidnewall.com> <20140524.230202.372276424258120234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140524.230202.372276424258120234.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25/05/14 12:32, David Miller wrote:
> From: David Newall<davidn@davidnewall.com>
> Date: Sun, 25 May 2014 12:02:03 +0930
>
>> On 25/05/14 03:13, David Miller wrote:
>>> This patch was substantially corrupted by your email client.
>> >We should be sending these things as mime attachments.
> It makes replying and commenting inline easy.

Patches are intrinsically corrupted by commenting on them inline, and 
that doesn't matter.  What does matter is when a patch that people will 
need to test is corrupted, and sending them as mime attachments is the 
best answer I know of.  It's trivial to copy and paste from an 
attachment to the body so that you can comment; far easier than copying 
and pasting a patch verbatim (i.e. without corrupting it.)


> It's not our problem that so many email clients make sending
> plain unmolested ASCII text difficult.

It wasn't the email client; it was the xfce-terminal copy that corrupted 
it.  It's proven to corrupt this patch in two different ways; the other, 
which I caught before send, was because of unreliable scrollback.

In fact it is our problem when we insist that patches be sent in a way 
which we know is brittle and error-prone; our problem and our fault.  
Just imagine if you could have back all of the time you've wasted 
looking at included code, only to discover that it had been corrupted in 
some way or another; and then multiply that by everybody else who's 
wasted time the same way.  The argument that it makes it easy to comment 
is unconvincing to me because the alternative is so easy.

I apologise for this noise as I don't believe this is something which 
will change any time soon; it will change, just not soon.  I'm quite 
willing to drop the issue.
