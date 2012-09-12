From: "Love, Robert W" <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 0/5] Reorganize libfcoe control
 interfaces
Date: Wed, 12 Sep 2012 19:35:18 +0000
Message-ID: <5050E3F5.3080008@intel.com>
References: <20120910225908.13140.97277.stgit@fritz>
 <CAHNqLyUUeVPVzvZCKzmbp0LdOGnOYudOehVfagySokrq8zj4hA@mail.gmail.com>
 <504F76A1.50809@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "devel-s9riP+hp16TNLxjTenLetw@public.gmane.org" <devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>,
 "linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Chris Leech <leech-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <504F76A1.50809-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Content-ID: <35A936175D2BFF4A9C3AD6302AFFAB80-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.open-fcoe.org/mailman/options/devel>,
 <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-fcoe.org/mailman/listinfo/devel>,
 <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12-09-11 10:36 AM, Love, Robert W wrote:
> On Tue 11 Sep 2012 10:06:29 AM PDT, Chris Leech wrote:
>> On Mon, Sep 10, 2012 at 3:59 PM, Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:

<snip>

> This feels a little awkward with all the special control files.  Have
> you thought about something designed for creating kernel objects, like
> configfs?  Similarly the separate start, enable, disable files vs.
> Let me do some more reading about configfs. I may not have given it
> enough thought.

I read though the configfs documentation and the fact that it's designed 
for user driven object creation does fit with what I'm trying to do. I 
have a couple concerns that I'm trying to sort through now-

1) This adds a new dependency for boot. I don't know if that is a 
problem or not. Are there any examples of configfs being mounted in an 
initrd?

2) Using configfs would likely mean that I'd be creating controller 
instances and possibly FCF instances in configfs, since they're already 
there in sysfs these objects would be duplicated. I'm not sure there's 
harm in that, but it certainly feels disjointed and messy. I suppose we 
could remove the /sys/bus/fcoe stuff in favor of configfs if it's the 
right thing to do.

Thanks, //Rob
