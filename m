From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Oops/Warning report for the week of March 28th 2008
Date: Fri, 28 Mar 2008 15:33:43 -0700
Message-ID: <47ED7247.3020203@linux.intel.com>
References: <47ED3F1A.1090101@linux.intel.com> <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758969AbYC1Wd7@vger.kernel.org>
In-Reply-To: <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> 
>> http://www.kerneloops.org/searchweek.php?search=input_release_device
> 
> The problem with kerneloops is that it seems to be really hard to figure 
> out the *source* of the oops. I can find the oopses (and it's really good 
> with the whole search-and-clump-together-by-version thing), but then when 
> some oops like this is found, it's hard to see where your kerneloops 
> scripts found the oops from, so the context of the oops is all gone.

the website has 2 (well 3) sources for oopses

1) Postings to LKML and related mailing list
2) kernel.org bugzilla bugs (but this technically goes via a mailing list so could count as #1)
3) a daemon/desktop applet application that will, when an oops is found in dmesg or /var/log/messages,
    pops up a dialog and asks if it's OK to submit the crash data. (always/yes/no/never)

Fedora 9 alpha / beta versions have this daemon/applet included (as does Gentoo and several other distros).

> Is there something obvious that I'm missing? I'd really like to see the 
> whole posting that the oops came from. Do you save the originals or even 
> just message ID's from the ones you pick from emails?

For the postings to LKML there is already a link to the message (based on msg id)
For bugzilla entries the website actually shows a bugzilla logo and links to the bug directly
For the daemon-submitted oopses there is no other data unfortunately (but this is for privacy
reasons; since no other info than the oops is submitted users are more likely to allow this)

The question (and it is a question still for me) is if those anonymous submissions are useful.
I think they are, since they allow for getting a more "neutral" measure of "which oopses are frequent"...
At least more neutral than "people who manage to notice an oops in dmesg and then post to LKML"...
And there's sometimes power in numbers.. for example in the do_sys_open() oops, I had like 20 no-info oopses,
but they ALL had nouveau in the modules list...

I can try doing some sorting tricks in the grouping, so that those oopses who have more data than this, show
up on top... (and maybe a direct link on the search page)
