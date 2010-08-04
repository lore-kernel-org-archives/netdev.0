From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free (after using openvpn)
Date: Wed, 04 Aug 2010 15:04:08 -0700
Message-ID: <m1ocdi6nmv.fsf_-_@fess.ebiederm.org>
References: <loom.20100708T183152-326@post.gmane.org>
	<20100709235744.GA12752@kroah.com>
	<20100710101540.2799c9ef@xenia.leun.net>
	<20100710140800.GA20424@kroah.com>
	<20100710165208.59272ae6@xenia.leun.net>
	<20100710235323.5336f627@xenia.leun.net>
	<20100711192939.1c25dcaf@xenia.leun.net>
	<20100804153543.56f6ecad@xenia.leun.net>
	<20100804214618.GA6289@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Leun <lkml20100708@newton.leun.net>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100804214618.GA6289@kroah.com> (Greg KH's message of "Wed\, 4 Aug 2010 14\:46\:18 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <greg@kroah.com> writes:

> On Wed, Aug 04, 2010 at 03:35:43PM +0200, Michael Leun wrote:
>> Hi,
>> 
>> On Sun, 11 Jul 2010 19:29:39 +0200
>> Michael Leun <lkml20100708@newton.leun.net> wrote:
>> 
>> [...]
>> > Jul 10 20:02:36 doris kernel: unregister_netdevice: waiting for lo to
>> > become free. Usage count = 3 [repeated]

Does this repeat indefinitely, or are there only a couple of repetitions?
If this repeats indefinitely every 5 seconds or so we have a serious bug.

Otherwise we just have cleanup taking longer than it should, which isn't
ideal but it is much less severe.

>> > Now one might say it is fault of openvpn (used OpenVPN 2.1_rc20
>> > i586-suse-linux - the one in openSuSE 11.2 package), openvpn didn't
>> > close some ressource and ssh does fine.
>> > 
>> > But: should'nt kernel clean up after process when it exits?
>> > And/or: Should'nt kernel clean up if last process in network namespace
>> > exits - there is nothing left which might use that interface?!
>> > 
>> > Greg KH <greg@kroah.com> wrote:
>> > 
>> > > Yes, you are correct.  Care to resend all of this to the
>> > > network-namespace developer(s) and the netdev mailing list so that
>> > > the correct people are notified so they can fix it all?
>> > 
>> > [X] done - hopefully, cannot find a particular network namespace
>> > developer in MAINTAINERS or source files. If such a one exists, please
>> > forward.
>> 
>> Did'nt work. Got no reaction from network mailinglist at all and bug
>> still is in 2.6.35.
>
> Eric, here's a bug with the network namespace stuff, care to work on
> resolving it?

Greg thanks for forwarding this in my direction.

Eric
