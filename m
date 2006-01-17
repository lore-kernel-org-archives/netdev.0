From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Tue, 17 Jan 2006 13:54:32 -0500
Message-ID: <3FE2A85B-6217-48C6-81B2-26501FE2B2EE@mac.com>
References: <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost> <20060114011726.GA19950@shaftnet.org> <43C97605.9030907@pobox.com> <20060115152034.GA1722@shaftnet.org> <Pine.LNX.4.58.0601152038540.19953@irie> <20060116170951.GA8596@shaftnet.org> <Pine.LNX.4.58.0601162020260.17348@irie> <20060116190629.GB5529@tuxdriver.com> <1137450281.15553.87.camel@localhost.localdomain> <20060117184114.GB20298@shaftnet.org>
Mime-Version: 1.0 (Apple Message framework v746.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"John W. Linville" <linville@tuxdriver.com>,
	Samuel Ortiz <samuel.ortiz@nokia.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964775AbWAQSzn@vger.kernel.org>
In-Reply-To: <20060117184114.GB20298@shaftnet.org>
To: Stuffed Crust <pizza@shaftnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jan 17, 2006, at 13:41, Stuffed Crust wrote:
> On Mon, Jan 16, 2006 at 10:24:41PM +0000, Alan Cox wrote:
>> If I have told my equipment to obey UK law I expect it to do so.  
>> If I hop on the train to France and forget to revise my  
>> configuration I'd prefer it also believed the APs
>
> It's not that you might forget to revise your configuration, but  
> that the vast majority of users will not revise anything, and still  
> expect things to "just work".  Kind of like multi-band cell phones.

Alan's point is still very valid.  From a poweruser point of view, if  
I specifically tell my wireless client "You must obey US laws", and  
then I wander over past a broken imported AP, I don't want my client  
to _expand_ its allowable range.  IMHO, userspace should be able to  
forcibly restrict wireless frequencies to a certain regdomain (or  
leave unrestricted and passive-scan-only), and specify how AP/ 
configured regdomains act.  Given the range of possibilities, I think  
that a userspace daemon monitoring events and dynamically configuring  
the useable frequencies would best.  That way the userspace daemon  
could be configured to ignore APs, union/intersect the APs with the  
configured regdomain, ignore the configured regdomain in the presence  
of APs, etc.

Cheers,
Kyle Moffett

--
I lost interest in "blade servers" when I found they didn't throw  
knives at people who weren't supposed to be in your machine room.
   -- Anthony de Boer
