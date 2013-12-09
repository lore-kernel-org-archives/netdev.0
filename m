From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Tue, 10 Dec 2013 00:05:44 +0200
Message-ID: <CAJZOPZLiQO2jnX5mgi0C07GfE354VsqhoEdRHCEahZtPoB7d2g@mail.gmail.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>
	<52A36235.1040406@cogentembedded.com>
	<1386440208.2195.3.camel@jtkirshe-mobl>
	<52A3812F.4070701@cogentembedded.com>
	<1386444985.2195.8.camel@jtkirshe-mobl>
	<52A39129.7090507@cogentembedded.com>
	<1386449757.2195.30.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53992 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761752Ab3LIWFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 17:05:45 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so6164583pbc.5
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 14:05:44 -0800 (PST)
In-Reply-To: <1386449757.2195.30.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 7, 2013 at 10:55 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Sun, 2013-12-08 at 00:20 +0300, Sergei Shtylyov wrote:
>> On 12/07/2013 10:36 PM, Jeff Kirsher wrote:
>>
>> >>>>> From: Anjali Singhai Jain <anjali.singhai@intel.com>
>>
>> >>>>> RSS can steer packets based on recognition of all
>> >>>>> sorts of different headers.  Enable some more of them.
>>
>> >>>>> Change-Id: I2264dedae66fb0bceca6fb6e772e050e3ca8efc8
>>
>> >>>>       This line has no place in the upstream patches, and I'm seeing it
>> >>>> in several patches of this series.
>>
>> >>> This is an internal hash id, so that we can track upstream changes back
>> >>> to internal git tree changes.  I did verify that this was acceptable and
>> >>> is being used in the kernel in upstream patches before pushing this
>> >>> information.
>>
>> >>      First time I hear about that. Its use is constantly denied in
>> >> linux-usb at least.  Maybe netdev has its own rules regarding this though...
>>
>>     Greg KH seems to be persistent in being negative towards its use. I also
>> react semi-automatically whenever I see it, asking to remove it. Anyway, it's
>> really DaveM's issue whether to allow it.
>>     The main issue with it is that it doesn't contain any useful information
>> to an ordinary person browsing kernel commits, it's exactly for the internal
>> use only.
>
> Well, I would disagree on the point that it would be for internal use
> only.  While it is a internal git hash, it helps us support the Linux
> community by helping us track the internal history of the patch for
> support and changes.  So customers could give us either the Linux kernel
> hash (in which turn we would find the internal hash id information from
> the patch description) or could give us the I<hash>.  So you are right,
> we would be the ones using the information to help support you and
> everyone else.

Jeff, thanks for sharing your thoughts and the deeper reasoning. I am
still not fully (and not that it has to be gating factor, but still,
lets discuss that a bit...) convinced  -- e.g you mention internal git
-- but the patch can be gone through large changes throughout the
submission process and @ the exterme can be totally different in
upstream vs. how it was in the internal git once submitted.

Shouldn't vendors actually seek to do that  the other way around? e.g
find a way to link plain upstream commit Hash to their feature request
/ bug reports / development trees and not plant the IHash on upstream?
just thinking out loud.



> Personally, the more information you can put in a patch description
> (without writing a novel), the better.  While I was not originally a fan
> of the "Change-Id:", the positives out-weighed any negative argument.


>
>>
>> > Take a look at `git log --format=oneline --grep="Change-Id"`
>> > You will see there are instances in arch as well as in wireless and in
>> > other areas as well.
>>
>>     I saw only 3 screens of commits (expected to see more) without much system.
>>
>> > So we are not doing something new or the only ones using this tag.
>>
>>     I didn't say that (in fact, quite the contrary).
>
> Sorry, I inferred that from the response you originally sent.
>
>>
>> > Google appears to be using it as well based the following information:
>> > https://gerrit-documentation.storage.googleapis.com/Documentation/2.7/user-changeid.html
>>
>>     Why should we care about what Google does?
>
> I was just giving you background on where this tag appeared to originate
> from.  I was not trying to say "Ooo Google does this, so we should
> too..."
>
>>
>> > Places using gerrit:
>> > http://code.google.com/p/gerrit/wiki/ShowCases
>> > This is the largest example of a "Change-Id:" tag that I know of.
>>
>>     I didn't see the Linux kernel in this list, only Android.
>
> Neither did I, but I did find the use of it in the Linux kernel before
> we decided to adopt the practice.
