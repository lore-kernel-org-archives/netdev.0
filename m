From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Sun, 03 Aug 2003 13:09:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2D41B7.7040205@pobox.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk> <20030801154021.GA7696@gtf.org> <20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk> <20030801162536.GA18574@gtf.org> <20030802222145.GE22222@parcelfarce.linux.theplanet.co.uk> <3F2C3C86.6000202@pobox.com> <20030803002744.GF22222@parcelfarce.linux.theplanet.co.uk> <3F2C7E12.8070904@pobox.com> <20030803145656.GI22222@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20030803145656.GI22222@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Sat, Aug 02, 2003 at 11:14:26PM -0400, Jeff Garzik wrote:
> 
>>Matthew Wilcox wrote:
>>
>>>Nothing stops it being implemented as a macro in kcompat.  Having it as
>>>an inline function gives it argument typechecking which always gives me
>>>the warm fuzzies.
>>
>>No, it _needs_ to be a macro for maximum flexibility.
>>
>>Most importantly, kcompat code may use '#ifndef SET_ETHTOOL_OPS' as a 
>>trigger, to signal that compat code is needed.  No need for drivers to 
>>create tons of kernel-version-code ifdefs, just to test for when 
>>ethtool_ops appeared in 2.6, for when it starts appearing in 2.4 vendor 
>>backports, and (possibly) 2.4 itself.  Also, doing it at the cpp level 
>>allows compat code to #undef it, if it _really_ knows what its doing, 
>>and the situation calls for it.
> 
> 
> OK.  At this point, I really feel like I'm getting in the way and
> hindering more than I'm helping.  Can I pass the torch to you and let
> you finish the job?


Sorry to give that impression :(  I think we're pretty much "there". 
But if you wanna hand it off to me for the last little bits, and 
merging, that's fine too.  I'll leave it up to you.

	Jeff
