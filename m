From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Wed, 18 Dec 2013 10:35:06 +1100
Message-ID: <CAGRGNgXJWw20q6Hd=e8dS4A+Ey8wPTLPGeg02-dJJOuCHH9AEA@mail.gmail.com>
References: <1342235583.20131211182804@eikelenboom.it> <CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com>
 <871324710.20131211191104@eikelenboom.it> <CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com>
 <1937118387.20131216122200@eikelenboom.it> <52AEE60B.6030509@broadcom.com>
 <19210260274.20131216135644@eikelenboom.it> <CAGRGNgXHemM2FfnXgW5RbzhFT+9SfUfVkjdysK3+=_u3hWSacw@mail.gmail.com>
 <1534126119.20131217104548@eikelenboom.it> <387552477.20131217213319@eikelenboom.it>
 <20131217212709.GB5624@decadent.org.uk> <1254825772.20131217224914@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Arend van Spriel <arend@broadcom.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Avinash Patil <avinashapatil@gmail.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1254825772.20131217224914@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Wed, Dec 18, 2013 at 8:49 AM, Sander Eikelenboom
<linux@eikelenboom.it> wrote:
>
> Tuesday, December 17, 2013, 10:27:09 PM, you wrote:
>
>> On Tue, Dec 17, 2013 at 09:33:19PM +0100, Sander Eikelenboom wrote:
>> Debian official kernels use modular drivers, and neither
>> initramfs-tools nor dracut includes wireless drivers in the initramfs.
>> If you build a custom kernel with built-in drivers then you most
>> likely don't need an initramfs at all.
>
>> As maintainer of crda in Debian, I could add an initramfs hook that
>> would include it in an initramfs.  But I don't understand why it would
>> be worth doing so.  Why is it so useful to have wireless drivers
>> built-in *and* an initramfs?  If you think I should do this then open
>> a bug (reportbug crda).
>
> Indeed, I looked for a crda hook for initramfs-tools but didn't find it, so skipped that idea
> for the moment.
>
> So if i combine the two .. it's essentially just a very bad idea to compile the wireless stuff in.
> It needs a access to a userland program at module load time, or it will block forever.

>From looking at the code and files in the Debian package, the CRDA
"calls" are actually events which are then handled by udev.

So what happens to events passed to udev which aren't handled by any
of it's (current) rules?

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
